class SubmissionBatch < ApplicationRecord
  belongs_to :assignment
  belongs_to :user
end
