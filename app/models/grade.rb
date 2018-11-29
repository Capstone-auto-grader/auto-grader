class Grade < ApplicationRecord
  belongs_to :student, class_name: 'User', foreign_key: :student_id
  belongs_to :ta, class_name: 'User', foreign_key: :ta_id
  belongs_to :assignment
end
