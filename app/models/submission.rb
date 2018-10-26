class Submission < ApplicationRecord
    mount_uploader :attachment, AttachmentUploader
end
