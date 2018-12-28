class Student < ApplicationRecord
  has_many :takes_class
  has_many :courses, through: :takes_class

  has_many :submissions
  has_many :assignments, through: :submissions
end
