class TaConflict < ApplicationRecord
  belongs_to :user
  belongs_to :conflict_student, class_name: 'Student'
end
