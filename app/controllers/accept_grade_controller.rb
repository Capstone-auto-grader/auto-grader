class AcceptGradeController < ApplicationController
  skip_before_action :verify_authenticity_token
  include AssignmentsHelper
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
      remaining_grades = submission.assignment.submissions.where.not(zip_uri: nil).where(grade_received: false).count
      puts remaining_grades
      if remaining_grades == 0
        submission.assignment.course.tas.each do |ta|
          puts "CREATING SUBMISSIONS"
          puts submission
          puts ta.id
          puts submission.assignment.id
          group = Submission.where(ta: ta, assignment: submission.assignment).where.not(zip_uri: nil).map do |subm|
            # puts subm.id
            "#{subm.zip_uri}-ta-new"
          end
          create_zip_from_batch group,submission.assignment.id,ta.id
        end

        all_subm_uris = Assignment.find(submission.assignment_id).submissions.select(&:is_valid).map &:zip_uri
        request_moss_grade all_subm_uris, submission.assignment_id

      end
    end
  end

  def accept_batch
    assignment_id = params[:assignment_id]
    ta_id = params[:ta_id]
    batch = SubmissionBatch.find_by(assignment_id: assignment_id, user_id: ta_id)
    batch.update_attribute(:zip_uri, params[:zip_name])
    batch.update_attribute(:validated, true)
    puts batch
  end

  def accept_moss
    assignment_id = params[:assignment_id]
    moss_url = params[:moss_url]
    assignment = Assignment.find(assignment_id)
    assignment.update_attribute(:moss_url, moss_url)
  end
end
