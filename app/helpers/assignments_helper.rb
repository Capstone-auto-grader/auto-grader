require 'zip'
include CoursesHelper

module AssignmentsHelper

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
        Submission.new(grade_received: false, ta_id: ta, student_id: student, assignment_id: assignment.resubmit.id, latte_id: resub_latte_ids[student])
      end
    end
    resubs.map &:save!

    submissions = resubs.map do |r|
      Submission.new(grade_received: false, ta_id: r.ta_id, student_id: r.student_id, assignment_id: assignment.id, latte_id: orig_latte_ids[r.student_id], resubmission_id: r.id)
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

  def csv_lines
    headers = ['Identifier', 'Full name', 'Email address', 'Status', 'Grade', 'Maximum Grade', 'Grade can be changed', 'Last modified (submission)', 'Last modified (grade)', 'Feedback comments']
    lines = []
    lines << headers
    @submissions.each do |s|
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

  def comment(submission)
    s = sub_comment(submission)
    s += sub_comment(submission.resubmission) if submission.resubmission.grade_received
    s.delete("\r").gsub("\n", '<br>')
  end

  def sub_comment(submission)
    s = submission.is_resubmission? ? "\n-----\nRESUBMISSION:\n" : ''

    return s + 'NO SUBMISSION' unless submission.grade_received
    return s + 'INVALID SUBMISSION' unless submission.is_valid

    s += "TESTS PASSED: #{submission.tests_passed}
TOTAL TESTS: #{submission.total_tests}
TEST GRADE: #{submission.test_grade}"

    s += "\n-----
TA GRADE: #{submission.ta_grade}
GRADING TA: #{submission.ta.name}" unless submission.ta_grade.nil?

    s += "-----\n#{submission.ta_comment}" unless submission.ta_comment.nil?

    s += "\n-----\nEXTRA CREDIT POINTS: #{submission.extra_credit_points}" unless submission.assignment.extra_credit.empty?

    s
  end

  def create_zip_from_submission_uris(submissions)
    folders = submissions.map{ |submission| unzip_from_s3_to_folder(submission)}
    zfpath = Rails.root.join('tmp', "student-partition-#{SecureRandom.hex(8)}.zip")
    Zip::File.open(zfpath, Zip::File::CREATE) do |zipfile|
      folders.each do |directory|
        Dir.glob(File.join(directory, '**', '{*,.*}')).each do |file|
          zipfile.add(file.sub("#{Dir.tmpdir}/", ''), file)
        end
      end
    end
    return zfpath
  end

  def unzip_from_s3_to_folder(uri)
    tmpdir = Dir.mktmpdir
    s3_file = S3_BUCKET.object(uri)
    # puts uri
    new_uri = download_to_tempfile(s3_file)
    puts "ENTERING EXTRACT ZIP #{uri}"
    extract_zip(new_uri, tmpdir)
    puts "EXITING EXTRACT ZIP #{uri}"
    puts uri
    puts tmpdir
    tmpdir
  end

  def download_to_tempfile(object)
    puts "DOWNLOADING TO TEMPFILE"
    puts object.key
    tempfile = Tempfile.new
    tempfile.binmode
    puts "WRITING TO #{object.key}"
    tempfile.write(open(object.presigned_url(:get, expires_in: 60)).read)
    tempfile.flush
    puts "WROTE TO#{object.key}"
    tempfile.close
    puts tempfile.path
    puts "AAA #{`ls #{tempfile.path}`}"
    tempfile.path
  end

  def extract_zip(file, destination)
    # FileUtils.mkdir_p(destination)
    puts file
    puts `ls #{file}`
    puts "LISTED FILE"
    Zip::File.open(file) do |zip_file|
      zip_file.each do |f|
        fpath = File.join(destination, f.name)
        zip_file.extract(f, fpath) unless File.exist?(fpath)
      end
    end
  end

end
