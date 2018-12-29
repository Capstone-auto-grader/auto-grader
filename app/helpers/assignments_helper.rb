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

  def create_grades_from_assignment(assignment, csv)
    student_arr = assignment.course.students.all.map &:id
    tas = assignment.course.tas.all
    ta_ids = tas.map &:id
    ta_conflicts = tas.map {|ta| [ta.id, ta.conflicts.map(&:id)]}.to_h
    # byebug
    latte_ids = get_latte_ids_and_validate_registrations(csv, assignment)
    assignments = assign_groups(student_arr,ta_ids,ta_conflicts)

    submissions = assignments.flat_map do |ta, students|
      students.map do |student|
        Submission.new(ta_id: ta, student_id: student, assignment_id: assignment.id, latte_id: latte_ids[student])
      end
    end
    submissions.map &:save!
  end

  def get_latte_ids_and_validate_registrations(csv, assignment)
    headers = csv[0]
    id_index = headers.index "﻿Identifier"
    email_index = headers.index "Email address"
    name_index = headers.index "Full name"

    data = csv.drop(1)
    latte_ids = Hash.new
    data.each do |curr|
      email = curr[email_index]
      name = curr[name_index]

      latte_id = curr[id_index]
      latte_id.slice! "Participant "
      latte_id = latte_id.to_i

      student = Student.find_or_create_by email: email
      if name != student.name
        student.name = name
        student.save!
      end

      if !student.courses.include? assignment.course
        student.courses << assignment.course
      end

      latte_ids[student.id] = latte_id

    end
    latte_ids
  end

  def csv_lines
    headers = ['Identifier', 'Full name', 'Email address', 'Status', 'Grade', 'Maximum Grade', 'Grade can be changed', 'Last modified (submission)', 'Last modified (grade)', 'Feedback comments']
    lines = []
    lines << headers
    @submissions.each do |s|
      curr_sub = []
      curr_sub[0] = "Participant #{s.latte_id}"
      curr_sub[1] = s.user.name
      curr_sub[2] = s.user.email
      curr_sub[4] = s.final_grade
      curr_sub[9] = "#{comment(s)}"
      lines << curr_sub
    end
    lines
  end

  def comment(submission)
    """TESTS PASSED: #{submission.tests_passed}
    TOTAL TESTS: #{submission.total_tests}
    TEST GRADE: #{submission.test_grade}
    -----
    TA GRADE: #{submission.ta_grade}
    GRADING TA: #{submission.ta.name}
    #{"-----\n#{submission.ta_comment}" if submission.ta_comment}"""
  end
end
