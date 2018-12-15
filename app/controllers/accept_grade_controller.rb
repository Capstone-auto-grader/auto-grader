class AcceptGradeController < ApplicationController
  skip_before_action :verify_authenticity_token
  def accept_grade
    status = params[:status]
    if status == "ok"
      submission = Submission.find(params[:id].to_i)
      if submission
        # TODO: Convert grade to int on frontend
        submission.grade = ((params[:number_of_tests].to_f - (params[:number_of_failures].to_f + params[:number_of_errors].to_f)) / params[:number_of_tests]) * 100
        submission.save!
      end
    elsif status == "failure"
      submission = Submission.find(params[:id].to_i)
      if submission
        submission.grade = 0
        submission.save!
      end
    end
    g = Grade.where(student_id: submission.user_id, assignment_id: submission.assignment_id).first
    # g.grade = submission.grade
    if g.submission.nil?
      g.submission = submission
    elsif g.submission.created_at < submission.created_at
      g.submission = submission
    end
    g.save!
  end
end
