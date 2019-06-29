class Assignment < ApplicationRecord
  belongs_to :course
  has_many :submissions
  has_many :students, through: :submissions
  belongs_to :container
  belongs_to :resubmit, class_name: 'Assignment', foreign_key: :resubmit_id, optional: true
  serialize :extra_credit, Hash
end
