require 'zip'
require 'net/http'
require 'tempfile'
class ValidateZipFileJob < ApplicationJob
  queue_as :default

  def perform(zip_uri, assignment_id)
    validate_each_file zip_uri,assignment_id
  end
  # def perform(file_name, submission_id)
  #   submission = Submission.find submission_id

  #   uploader = AttachmentUploader.new
  #   uploader.retrieve_from_store! file_name
  #   if validate(uploader.path, structure_hash)
  #
  #
  #     buckob = S3_BUCKET.object file_name
  #     buckob.upload_file uploader.path
  #     submission.zip_uri = "#{S3_BUCKET.name}/#{buckob.key}"
  #     submission.save!
  #     uploader.remove!
  #
  #     uri = URI.parse("#{ENV['GRADING_SERVER']}/grade")
  #     http = Net::HTTP.new(uri.host, uri.port)
  #     req = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
  #     req.body = {proj_id: submission.id, proj_zip: submission.zip_uri, test_zip: submission.assignment.test_uri, image_name: 'java' }.to_json
  #     puts req.body
  #     res = http.request req
  #   else
  #     # Send out an email error message
  #     puts "NOT VALIDATED"
  #   end
  #   # Send post to grading API
  # end

  def validate(zip_uri, proj_structure)
    puts "URI"
    puts zip_uri
    Zip::File.open(zip_uri) do |zip_file|
      zip_file.each do |entry|
        proj_structure.keys.each do |key|
          if entry.name.include? key.to_s
            proj_structure[key] = true
          end
        end
      end
      return proj_structure.values.all?
    end
  end

  def validate_each_file(zip_name, assignment_id)
    uploader = AttachmentUploader.new
    uploader.retrieve_from_store! zip_name
    assignment = Assignment.find(assignment_id)
    Zip::File.open(uploader.path) do |submission_folder|
      submission_folder.each do |zip|
        split_name = zip.name.split('_')
        latte_id = split_name[1]
        tempfile = Tempfile.new("#{assignment_id}_#{latte_id}")
        # to get that: .basename
        tempfile.binmode
        tempfile.write zip.get_input_stream.read
        # puts tempfile.size
        tempfile.flush
        submission = Submission.find_by(assignment_id: assignment_id, latte_id: latte_id)
        # puts "BEGIN"
        # puts submission.id
        # puts submission.assignment
        # puts "END"
        structure_arr = submission.assignment.structure
        structure_hash = structure_arr.map {|elem| [elem, false]}.to_h
        if validate(tempfile.path, structure_hash)
          upload_tempfile_to_s3(tempfile, submission)
          post_submission_to_api(submission)
        end

      end
      # basename = File.basename(submission_folder.name)
      #
      #
      # tempfile = Tempfile.new(basename)
      # tempfile.binmode
      # tempfile.write submission_folder.get_input_stream.read
    end
  end

  def post_submission_to_api(submission)
    uri = URI.parse("#{ENV['GRADING_SERVER']}/grade")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
    req.body = {proj_id: submission.id, proj_zip: submission.zip_uri, test_zip: submission.assignment.test_uri, image_name: 'java' }.to_json
    puts req.body
    res = http.request req
  end

  def upload_tempfile_to_s3(tempfile, submission)
    buckob = S3_BUCKET.object File.basename(tempfile.path)
    buckob.upload_file tempfile.path
    submission.zip_uri = "#{S3_BUCKET.name}/#{buckob.key}"
  end
end
