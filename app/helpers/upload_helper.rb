module UploadHelper

  def submit(zip, submission)
    upload_tempfile_to_s3(zip, submission)
    post_submission_to_api(submission)
  end

  def post_submission_to_api(submission, rerun = false)
    uri = URI.parse("#{ENV['GRADING_SERVER']}/grade")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
    image_name = submission.assignment.container_name.nil? ? 'java' :  submission.assignment.container_name
    req.body = { proj_id: submission.id, proj_zip: submission.zip_uri, test_zip: submission.assignment.test_uri, image_name: image_name, student_name: submission.student.name, sec: submission.security_hash, rerun: rerun}.to_json
    puts req.body
    http.request req
  end

  def upload_tempfile_to_s3(zip, submission)
    tempfile = build_tempfile(zip)
    buckob = S3_BUCKET.object s3_name(submission)
    buckob.upload_file tempfile.path
    sec_hash = SecureRandom.hex(16)
    submission.update_attributes(zip_uri: "#{S3_BUCKET.name}/#{buckob.key}", security_hash: sec_hash)
  end

  def s3_name(submission)
    uid = submission.student.email.split('@')[0]
    pa_name = submission.assignment.name.tr(' ', '-')
    latte_id = submission.latte_id
    "#{uid}_#{pa_name}_#{latte_id}_#{Time.new.to_i}"
  end

  def build_tempfile(zip)
    tempfile = Tempfile.new
    tempfile.binmode
    tempfile.write zip.read
    tempfile.flush
    tempfile
  end

  def make_batches(assignment)
    assignment.course.tas.each do |ta|
      create_zip_from_batch submission.assignment.id, ta.id
    end
  end

end
