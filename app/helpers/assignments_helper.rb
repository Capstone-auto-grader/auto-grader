module AssignmentsHelper
  def assign(students, tas, conflicts)
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
end
