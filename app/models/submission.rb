class Submission < ApplicationRecord
  belongs_to :assignment
  belongs_to :student
  belongs_to :ta, class_name: 'User', foreign_key: :ta_id
  belongs_to :resubmission, class_name: 'Submission', foreign_key: :resubmission_id, optional: true

  def has_grade?
    !test_grade.nil?
  end

  def is_resubmission?
    resubmission.nil?
  end

  def final_grade
    test_weight = assignment.test_grade_weight / 100.0
    ta_weight = 1 - test_weight


    ta_grade = self.ta_grade || Submission.find_by(resubmission_id: id).ta_grade

    original_result = (test_weight * test_grade) + (ta_weight * ta_grade)
    if is_resubmission? || !resubmission.has_grade?
      original_result
    else
      resubmit_result = (original_result + resubmission.final_grade) / 2
      [original_result, resubmit_result].max
    end
  end
end
