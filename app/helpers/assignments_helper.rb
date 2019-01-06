module AssignmentsHelper
  def assign_groups(students, tas, conflicts)
    shuffled_students = students.shuffle
    ret_hash = tas.map { |t| [t,[]] }.to_h
    while ! shuffled_students.empty?
      tmp = []
      while conflicts[tas[0]].include?(student = shuffled_students.pop)
        tmp << student
      end
      if !student.nil?
        ret_hash[tas[0]] << student
      end
      shuffled_students += tmp
      tas = tas.rotate
    end
    ret_hash
  end

  def create_submissions_from_assignment(assignment, orig_csv, resub_csv)
    puts "ASSIGNMENT #{assignment.id}"
    orig_latte_ids, resub_latte_ids = get_latte_ids_and_validate_registrations(orig_csv, resub_csv, assignment)

    student_arr = orig_latte_ids.keys
    tas = assignment.course.tas.all
    ta_ids = tas.map &:id
    ta_conflicts = tas.map {|ta| [ta.id, ta.conflicts.map(&:id)]}.to_h

    assignments = assign_groups(student_arr,ta_ids,ta_conflicts)
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
    if submission.resubmission.grade_received
      sub_comment(submission) + sub_comment(submission.resubmission)
    else
      sub_comment(submission)
    end
  end


  def sub_comment(submission)
    s = "#{"\n-----\nRESUBMISSION:\n" if submission.is_resubmission?}TESTS PASSED: #{submission.tests_passed}
TOTAL TESTS: #{submission.total_tests}
TEST GRADE: #{submission.test_grade}"
    s += "\n-----
TA GRADE: #{submission.ta_grade}
GRADING TA: #{submission.ta.name}
#{"-----\n#{submission.ta_comment}" if submission.ta_comment}" unless submission.ta_grade.nil?
    s.delete("\r").gsub("\n", "<br>")
  end

end
