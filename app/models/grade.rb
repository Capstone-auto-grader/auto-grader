class Grade < ApplicationRecord
  belongs_to :student, class_name: 'User', foreign_key: :student_id
  belongs_to :ta, class_name: 'User', foreign_key: :ta_id
  belongs_to :assignment
  has_one :submission

  # Idea-- have list of conflicts
  # Assign conflicts to grading TAs first
  # Then, subtract all conflicts from total set of students,
  # randomly order,
  # and randomly assign until each TA has a relatively equal number
  #
  #
  # Grade where assignment is assignment id each
  # idea << map each student to a TA, rather than the other way around

  def final_grade
    test_weight = assignment.test_grade_weight.to_f / 100
    test_grade_weighted = test_weight * submission.test_grade

    ta_weight = 1 - test_weight
    ta_grade_weighted = ta_weight * ta_grade

    test_grade_weighted + ta_grade_weighted
  end
end
