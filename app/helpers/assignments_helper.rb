require 'zip'
include CoursesHelper

module AssignmentsHelper

  def get_avg_test(assignment)
      all_subs = Submission.where(assignment_id: assignment.id)

      test_avg = all_subs.average(:tests_passed) || 0
      num_tests = all_subs.where.not(total_tests: nil).pluck(:total_tests).max || 1

      test_avg = (100 * test_avg.to_f / num_tests).round(2)
  end

  def get_group_offset(course_id)
    course = Course.find(course_id)
    last = course.assignments.last
    if last.nil?
      0
    else
      (last.group_offset + 1) % course.tas.count
    end
  end

  def assign_tas(assignment, tas, conflicts)
    enrollments = assignment.course.takes_class
    offset = assignment.group_offset
    ta_count = tas.count
    ret_hash = tas.map { |t| [t, []] }.to_h
    enrollments.each do |e|
      index = (e.group + offset) % ta_count
      ret_hash[tas[index]] << e.student.id
    end

    tas.each do |t|
      ret_hash[t].each do |s|
        find_swap(t, s, tas, conflicts, ret_hash) if conflicts[t].include? s
      end
    end

    tas.each do |ta|
      SubmissionBatch.create(user_id: ta, assignment: @assignment)
      SubmissionBatch.create(user_id: ta, assignment: @assignment.resubmit)
    end

    ret_hash
  end

  def find_swap(ta, student, tas, conflicts, hash)
    start_index = (tas.index(ta) + (tas.count/2)) % tas.count
    candidate_swaps = tas.rotate(start_index).reject { |c| conflicts[c].include? student }
    candidate_swaps.each do |new_ta|
      hash[new_ta].shuffle.each do |new_student|
        unless conflicts[ta].include? new_student
          hash[ta].delete student
          hash[new_ta] << student

          hash[new_ta].delete new_student
          hash[ta] << new_student
          return
        end
      end
    end
  end

  def create_submissions_from_assignment(assignment, orig_csv, resub_csv)
    puts "ASSIGNMENT #{assignment.id}"
    orig_latte_ids, resub_latte_ids = get_latte_ids_and_validate_registrations(orig_csv, resub_csv, assignment)

    reassign_groups(assignment.course)

    tas = assignment.course.tas.all
    ta_conflicts = tas.map {|ta| [ta.id, ta.conflict_students.map(&:id)]}.to_h

    assignments = assign_tas(assignment, tas.pluck(:id), ta_conflicts)
    resubs = assignments.flat_map do |ta, students|
      students.map do |student|
        Submission.new(grade_received: false, ta_id: ta, student_id: student, assignment_id: assignment.resubmit.id, latte_id: resub_latte_ids[student], late_penalty: 0)
      end
    end
    resubs.map &:save!

    submissions = resubs.map do |r|
      Submission.new(grade_received: false, ta_id: r.ta_id, ta_grade: 0, student_id: r.student_id, assignment_id: assignment.id, latte_id: orig_latte_ids[r.student_id], resubmission_id: r.id, late_penalty: 0)
    end
    submissions.map &:save!

    puts submissions.map(&:assignment_id)
  end

  def get_latte_ids_and_validate_registrations(orig_csv, resub_csv, assignment)
    headers = orig_csv[0]
    id_index = headers.index "﻿Identifier"
    email_index = headers.index "Email address"
    name_index = headers.index "Full name"

    orig_data = orig_csv.drop(1)
    resub_data = resub_csv.drop(1)
    orig_latte_ids = Hash.new
    resub_latte_ids = Hash.new
    orig_data.each do |curr|
      email = curr[email_index]
      name = curr[name_index]

      orig_latte_id = to_latte_id(curr[id_index])

      student = Student.find_or_create_by email: email
      if name != student.name
        student.name = name
        student.save!
      end

      student.courses << assignment.course unless student.courses.include? assignment.course

      orig_latte_ids[student.id] = orig_latte_id

      resub_student_index = resub_data.map { |d| d[email_index] }.index email
      resub_latte_id = resub_data[resub_student_index][id_index]
      resub_latte_ids[student.id] = to_latte_id(resub_latte_id)

    end
    [orig_latte_ids, resub_latte_ids]
  end

  def to_latte_id(s)
    s.slice! 'Participant '
    s.to_i
  end

  def latte_csv_lines
    submissions = @assignment.submissions
    submissions = submissions.where.not(ta_grade: nil) unless @assignment.test_grade_weight == 100
    headers = ['Identifier', 'Full name', 'Email address', 'Status', 'Grade', 'Maximum Grade', 'Grade can be changed', 'Last modified (submission)', 'Last modified (grade)', 'Feedback comments']
    lines = []
    lines << headers
    submissions.each do |s|
      curr_sub = []
      curr_sub[0] = "Participant #{s.latte_id}"
      curr_sub[1] = s.student.name
      curr_sub[2] = s.student.email
      curr_sub[4] = s.final_grade
      curr_sub[9] = comment(s)
      lines << curr_sub
    end
    lines
  end

  def tom_csv_lines
    submissions = @assignment.submissions.sort_by { |s| s.student.name }
    puts submissions.select { |s| !s.total_tests.nil? }
    total_tests = submissions.select { |s| !s.total_tests.nil? }.first.total_tests
    headers = %w[NAME EMAIL
                 COMMENT NUM_TESTS
                 NUM_FAILS SUBMIT_GRADE
                 RESUBMIT_GRADE TA_GRADE
                 TA_NAME FINAL_GRADE]
    lines = [headers]
    submissions.each do |s|
      lines << [s.student.name, s.student.email,
                comment(s), total_tests,
                s.tests_passed ? total_tests - s.tests_passed : 0, s.test_grade,
                s.resubmission.test_grade, s.ta_grade,
                s.ta.name, s.final_grade]
    end
    lines
  end

  def comment(submission)
    return submission.comment_override unless submission.comment_override.nil?
    s = sub_comment(submission)
    s += sub_comment(submission.resubmission) if submission.resubmission.grade_received
    s.delete("\r").gsub("\n", '<br>')
  end

  def sub_comment(submission)
    s = submission.is_resubmission? ? "\n-----\nRESUBMISSION:\n" : ''

    return s + 'NO SUBMISSION' unless submission.grade_received

    if submission.is_valid?
      s += "TESTS PASSED: #{submission.tests_passed}
TOTAL TESTS: #{submission.total_tests}
TEST GRADE: #{submission.test_grade}"
    else
      s += 'INVALID SUBMISSION'
    end


    s += "\n-----
TA GRADE: #{submission.ta_grade}
GRADING TA: #{submission.ta.name}" unless submission.ta_grade.nil?

    s += "\n-----\n#{submission.ta_comment}" unless submission.ta_comment.nil?
    s += "\n-----\nLATE PENALTY: -#{submission.late_penalty}" unless submission.late_penalty.zero?
    s += "\n-----\nEXTRA CREDIT POINTS: #{submission.extra_credit_points}" unless submission.extra_credit_points.nil? || submission.extra_credit_points.zero?

    s
  end


  def create_zip_from_batch(assignment_id, ta_id)
    submissions = Submission.where(ta_id: ta_id, assignment_id: assignment_id).where.not(zip_uri: nil).map { |s| "#{s.zip_uri}-ta-new"}
    uri = URI.parse("#{ENV['GRADING_SERVER']}/batch")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
    req.body = {image_name: 'batch', zip_name: "#{assignment_id}-#{ta_id}-submissions.zip", uris: submissions, assignment_id: assignment_id, ta_id: ta_id}.to_json
    # puts req.body
    puts "REQ"
    puts http.request req

  end

  def request_moss_grade(uris, assignment_id)
    uri = URI.parse("#{ENV['GRADING_SERVER']}/moss")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
    req.body ={assignment_id: assignment_id, uris: uris, base_uri: Assignment.find(assignment_id).base_uri}.to_json
    puts http.request req

  end
  # def unzip_from_s3_to_folder(uri)
  #   puts uri
  #   tmpdir = Dir.mktmpdir
  #   s3_file = S3_BUCKET.object(uri)
  #   uri = download_to_tempfile(s3_file)
  #   extract_zip(uri, tmpdir)
  #   tmpdir
  # end
  #
  # def download_to_tempfile(object)
  #   tempfile = Tempfile.new
  #   tempfile.binmode
  #   tempfile.write(open(object.presigned_url(:get, expires_in: 60)).read)
  #   tempfile.flush
  #   tempfile.path
  # end
  #
  # def extract_zip(file, destination)
  #   # FileUtils.mkdir_p(destination)
  #
  #   Zip::File.open(file) do |zip_file|
  #     zip_file.each do |f|
  #       fpath = File.join(destination, f.name)
  #       zip_file.extract(f, fpath) unless File.exist?(fpath)
  #     end
  #   end
  # end

end
