require 'zip'
require 'net/http'
require 'tempfile'
require 'securerandom'
class UploadIndividualZipFileJob < ApplicationJob
  include UploadHelper
  queue_as :default

  def perform(zip_name, submission_id)
    uploader = AttachmentUploader.new
    uploader.retrieve_from_store! zip_name

    submission = Submission.find(submission_id)
    puts uploader.path
    submit(open(uploader.path), submission) unless submission.grade_received

  end

end
