class AcceptGradeController < ApplicationController

  def accept_grade
    status = params[:status]
    if status == "ok"
      submission = Submission.find(params[:id].to_i)
      if submission
        submission.grade = (params[:number_of_tests].to_f - params[:number_of_failures].to_f) / params[:number_of_tests]
        submission.save!
      end
    end
  end
end
