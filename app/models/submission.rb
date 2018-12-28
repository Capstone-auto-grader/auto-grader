class Submission < ApplicationRecord
  belongs_to :assignment
  belongs_to :student
  belongs_to :ta, class_name: 'User', foreign_key: :ta_id

  def final_grade
    test_weight = assignment.test_grade_weight.to_f / 100
    test_grade_weighted = test_weight * submission.test_grade

    ta_weight = 1 - test_weight
    ta_grade_weighted = ta_weight * ta_grade

    test_grade_weighted + ta_grade_weighted
  end
end
