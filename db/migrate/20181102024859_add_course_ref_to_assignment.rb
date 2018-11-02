class AddCourseRefToAssignment < ActiveRecord::Migration[5.2]
  def change
    add_reference :assignments, :courses, index: true
  end
end
