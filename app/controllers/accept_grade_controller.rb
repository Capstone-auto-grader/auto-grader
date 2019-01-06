class AcceptGradeController < ApplicationController
  skip_before_action :verify_authenticity_token
  def accept_grade
    status = params[:status]
    submission = Submission.find(params[:id].to_i)
    if submission
      if status == "ok"
        # TODO: Convert grade to int on frontend
        total_tests = params[:number_of_tests]
        tests_passed = total_tests - (params[:number_of_failures] + params[:number_of_errors])
        submission.tests_passed = tests_passed
        submission.total_tests = total_tests
      else
        submission.tests_passed = 0
        submission.total_tests = 0
      end
      submission.grade_received = true
      submission.save!
    end
  end
end
