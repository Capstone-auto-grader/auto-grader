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
      # upload to S3

      buckob = S3_BUCKET.object file_name
      buckob.upload_file uploader.path
      submission.zip_uri = buckob.public_url
      submission.save!
      uploader.remove!
      puts "VALIDATED"
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
