class AcceptGradeController < ApplicationController
  skip_before_action :verify_authenticity_token
  include AssignmentsHelper
  include UploadHelper
  def accept_grade
    status = params[:status]
    submission = Submission.find(params[:id].to_i)
    if submission
      if submission.security_hash != params[:sec]
        return
      end
      if status == 'ok'
        # TODO: Convert grade to int on frontend
        # extra_credit = submission.assignment.extra_credit
        # total_tests = params[:number_of_tests] - extra_credit.keys.count
        # ec_points = 0
        # ec_failures = 0
        failures = params[:failures].keys
        # extra_credit.each do |test, points|
        #   if failures.include? test
        #     ec_failures += 1
        #   else
        #     ec_points += points
        #   end
        # end
        # if submission.is_resubmassion?
        #   ec_points -= (submission.original.extra_credit_points || 0)
        #   ec_points /= 2.0
        #   ec_points = [ec_points, 0].max
        # end
        # tests_passed = total_tests - (failures.count - ec_failures)
        if submission.assignment.has_tests
          total_tests = params[:number_of_tests]
          tests_passed = params[:number_of_tests] - (params[:number_of_failures] + params[:number_of_errors])
          submission.tests_passed = tests_passed
          submission.total_tests = total_tests
        end

        # submission.extra_credit_points = ec_points
        submission.is_valid = true
      else
        submission.is_valid = false
      end
      submission.grade_received = true
      submission.save!
      remaining_grades = submission.assignment.submissions.where.not(zip_uri: nil).where(grade_received: false).count
      if remaining_grades == 0 && params[:rerun] != "true"
        puts "CREATING BATCHES"
        make_batches submission.assignment
      end
      if params['rerun'] == "true"
        create_zip_from_batch submission.assignment.id, submission.ta.id
      end
    end
  end

  def accept_batch
    assignment_id = params[:assignment_id]
    ta_id = params[:ta_id]
    batch = SubmissionBatch.find_by(assignment_id: assignment_id, user_id: ta_id)
    batch.update_attribute(:zip_uri, params[:zip_name])
    batch.update_attribute(:validated, true)
    puts SubmissionBatch.where(assignment_id: assignment_id, validated: false).length
    # if SubmissionBatch.where(assignment_id: assignment_id, validated: false).length == 0
    #   all_subm_uris = Assignment.find(assignment_id).submissions.map(&:zip_uri).reject{|elem| elem.nil?}
    #   request_moss_grade all_subm_uris, assignment_id
    #   puts "MOSS GRADE STARTED"
    # end
  end

  def accept_moss
    assignment_id = params[:assignment_id]
    moss_url = params[:moss_url]
    assignment = Assignment.find(assignment_id)
    assignment.update_attribute(:moss_url, moss_url)
    assignment.update_attribute(:moss_running, false)
  end
end
