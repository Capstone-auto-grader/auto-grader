require 'zip'
require 'net/http'
require 'tempfile'
require 'securerandom'
class UploadBulkZipFileJob < ApplicationJob
  include UploadHelper
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

        submit(zip.get_input_stream, submission) unless submission.grade_received
      end
    end
  end
end
