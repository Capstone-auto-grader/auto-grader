module SubmissionsHelper
  def status_or_grade(submission)
    return 'No submission' if submission.zip_uri.nil?
    return 'Pending' unless submission.grade_received

    submission.is_valid ? submission.test_grade : 'Invalid submission'
  end
end
