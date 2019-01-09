class AcceptGradeController < ApplicationController
  skip_before_action :verify_authenticity_token
  def accept_grade
    status = params[:status]
    submission = Submission.find(params[:id].to_i)
    if submission
      if status == 'ok'
        # TODO: Convert grade to int on frontend
        extra_credit = submission.assignment.extra_credit
        total_tests = params[:number_of_tests] - extra_credit.keys.count
        ec_points = 0
        ec_failures = 0
        failures = params[:failures].keys
        extra_credit.each do |test, points|
          if failures.include? test
            ec_failures += 1
          else
            ec_points += points
          end
        end
        if submission.is_resubmission?
          ec_points -= (submission.original.extra_credit_points || 0)
          ec_points /= 2.0
        end
        tests_passed = total_tests - (failures.count - ec_failures)
        submission.tests_passed = tests_passed
        submission.total_tests = total_tests
        submission.extra_credit_points = ec_points
        submission.is_valid = true
      else
        submission.is_valid = false
      end
      submission.grade_received = true
      submission.save!
    end
  end
end
