module SubmissionsHelper
  def status_or_grade(submission)
    return 'No submission' if submission.zip_uri.nil?
    return 'Pending' unless submission.grade_received

    return 'No tests' if submission.assignment.test_grade_weight.zero?

    submission.is_valid ? submission.test_grade : 'Invalid submission'
  end
end
