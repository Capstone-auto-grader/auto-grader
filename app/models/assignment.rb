class Assignment < ApplicationRecord
  belongs_to :course
  has_many :submissions
  serialize :structure, Array
end
