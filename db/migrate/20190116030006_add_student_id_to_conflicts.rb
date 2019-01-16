class AddStudentIdToConflicts < ActiveRecord::Migration[5.2]
  def change
    remove_column :ta_conflicts, :conflict_id
    add_column :ta_conflicts, :conflict_student_id, :integer
  end
end
