require 'zip'
require 'net/http'
class ValidateZipFileJob < ApplicationJob
  queue_as :default

  def perform(file_name, submission_id)
    submission = Submission.find submission_id
    structure_arr = submission.assignment.structure
    structure_hash = structure_arr.map {|elem| [elem, false]}.to_h
    uploader = AttachmentUploader.new
    uploader.retrieve_from_store! file_name
    if validate(uploader.path, structure_hash)


      buckob = S3_BUCKET.object file_name
      buckob.upload_file uploader.path
      submission.zip_uri = "#{S3_BUCKET.name}/#{buckob.key}"
      submission.save!
      uploader.remove!
      puts "VALIDATED"
      puts "#{ENV['GRADING_SERVER']}/grade"
      uri = URI.parse("#{ENV['GRADING_SERVER']}/grade")
      puts uri
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
      puts req
      req.body = {proj_id: submission.id, proj_zip: submission.zip_uri, test_zip: submission.assignment.test_uri }.to_json
      puts req.body
      res = http.request req
      puts res
    else
      # Send out an email error message
      puts "NOT VALIDATED"
    end
    # Send post to grading API
  end

  def validate(zip_uri, proj_structure)

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
end
