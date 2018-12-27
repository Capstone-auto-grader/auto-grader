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

  def create_grades_from_assignment(assignment)
    student_arr = assignment.course.students.all.map &:id
    tas = assignment.course.tas.all
    ta_ids = tas.map &:id
    ta_conflicts = tas.map {|ta| [ta.id, ta.conflicts.map(&:id)]}.to_h
    assignments = assign_groups(student_arr,ta_ids,ta_conflicts)
    grades = assignments.flat_map do |ta, students|
      students.map do |student|
        Grade.new(ta_id: ta, student_id: student, assignment_id: assignment.id)
      end
    end
    grades.map &:save!
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
      curr_sub[4] = s.grade.final_grade
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
    TA GRADE: #{submission.grade.ta_grade}
    GRADING TA: #{submission.grade.ta.name}
    #{"-----\n#{submission.grade.custom_comment}" if submission.grade.custom_comment}"""
  end
end
