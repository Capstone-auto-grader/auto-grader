class Assignment < ApplicationRecord
  belongs_to :course
  has_many :submissions
  has_many :grades
  serialize :structure, Array
end
