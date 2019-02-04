class Submission < ApplicationRecord
  belongs_to :assignment
  belongs_to :student
  belongs_to :ta, class_name: 'User', foreign_key: :ta_id
  belongs_to :resubmission, class_name: 'Submission', foreign_key: :resubmission_id, optional: true

  def is_resubmission?
    resubmission.nil?
  end

  def original
    Submission.find_by(resubmission_id: id)
  end

  def test_grade
    if !is_valid || !grade_received || total_tests.zero?
      0.0
    else
      ((tests_passed.to_f * 100) / total_tests).round(3)
    end
  end

  def final_grade
    return final_grade_override unless final_grade_override.nil?
    return 0 if !is_valid || zip_uri.nil?

    test_weight = assignment.test_grade_weight / 100.0
    ta_weight = 1 - test_weight

    ta_grade = self.ta_grade || original.ta_grade

    original_result = (test_weight * test_grade) + (ta_weight * ta_grade)
    if is_resubmission? || !resubmission.grade_received
      result = original_result
    else
      resubmit_result = (original_result + resubmission.final_grade) / 2
      result = [original_result, resubmit_result].max
    end
    [result.round(2) - late_penalty, 0.0].max
  end
end
