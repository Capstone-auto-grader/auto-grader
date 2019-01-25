module CoursesHelper

  def reassign_groups(course)
    ta_count = course.tas.count
    enrollments = course.takes_class
    enrollments = course.takes_class.where(group: nil) if ta_count - 1 == enrollments.pluck(:group).reject(&:nil?).max

    enrollments.shuffle.each do |e|
      freq = Hash.new(0)
      (0..ta_count - 1).each { |x| freq[x] = 0 }
      freq = course.takes_class.pluck(:group).inject(freq) { |p, v| p[v] += 1; p }
      freq_arr = freq.keys.to_a
      freq_arr.delete(nil)
      groups = freq_arr.sort_by { |k| freq[k] }
      e.update(group: groups.first)
    end
  end

end
