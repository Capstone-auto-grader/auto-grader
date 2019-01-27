class TaConflict < ApplicationRecord
  belongs_to :conflict_ta, class_name: 'User', foreign_key: :user_id
  belongs_to :conflict_student, class_name: 'Student'
end
