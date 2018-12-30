class Assignment < ApplicationRecord
  belongs_to :course
  has_many :submissions
  has_many :students, through: :submissions
  has_many :grades
  serialize :structure, Array

  belongs_to :resubmit, class_name: 'Assignment', foreign_key: :resubmit_id, optional: true
end
