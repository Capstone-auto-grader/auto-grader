require 'zip'
require 'net/http'
require 'tempfile'
require 'securerandom'
class UploadZipFileJob < ApplicationJob
  queue_as :default

  def perform(zip_uri, assignment_id)
    upload_each_file zip_uri, assignment_id
  end

  def upload_each_file(zip_name, assignment_id)
    uploader = AttachmentUploader.new
    uploader.retrieve_from_store! zip_name
    Zip::File.open(uploader.path) do |submission_folder|
      submission_folder.each do |zip|
        split_name = zip.name.split('_')
        latte_id = split_name[1]
        submission = Submission.find_by(assignment_id: assignment_id, latte_id: latte_id)

        submit(zip, submission) unless submission.grade_received
      end
    end
  end

  def submit(zip, submission)
    upload_tempfile_to_s3(zip, submission)
    post_submission_to_api(submission)
  end

  def post_submission_to_api(submission)
    uri = URI.parse("#{ENV['GRADING_SERVER']}/grade")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
    req.body = { proj_id: submission.id, proj_zip: submission.zip_uri, test_zip: submission.assignment.test_uri, image_name: 'java', student_name: submission.student.name, sec: submission.security_hash}.to_json
    puts req.body
    http.request req
  end

  def upload_tempfile_to_s3(zip, submission)
    tempfile = build_tempfile(zip, submission)
    buckob = S3_BUCKET.object s3_name(submission)
    buckob.upload_file tempfile.path
    sec_hash = SecureRandom.hex(16)
    submission.update_attributes(zip_uri: "#{S3_BUCKET.name}/#{buckob.key}", security_hash: sec_hash)
  end

  def s3_name(submission)
    uid = submission.student.email.split('@')[0]
    pa_name = submission.assignment.name.tr(' ', '-')
    latte_id = submission.latte_id
    "#{uid}_#{pa_name}_#{latte_id}_#{Time.new.to_i}"
  end

  def build_tempfile(zip, submission)
    tempfile = Tempfile.new
    tempfile.binmode
    tempfile.write zip.get_input_stream.read
    tempfile.flush
    tempfile
  end
end
