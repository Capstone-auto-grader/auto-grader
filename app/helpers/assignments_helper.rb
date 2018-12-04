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
end
