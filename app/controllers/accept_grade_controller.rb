class AcceptGradeController < ApplicationController
  skip_before_action :verify_authenticity_token
  def accept_grade
    status = params[:status]
    if status == "ok"
      submission = Submission.find(params[:id].to_i)
      if submission
        # TODO: Convert grade to int on frontend
        submission.grade = ((params[:number_of_tests].to_f - params[:number_of_failures].to_f) / params[:number_of_tests]) * 100
        submission.save!
      end
    end
  end
end
