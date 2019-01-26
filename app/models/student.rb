class Student < ApplicationRecord
  has_many :takes_class
  has_many :courses, through: :takes_class

  has_many :submissions
  has_many :assignments, through: :submissions

  has_many :ta_conflicts, foreign_key: :conflict_student_id
  has_many :conflict_tas, through: :ta_conflicts
end
