class AddForeignKeyToTaConflicts < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :ta_conflicts, :users, column: :student_id
  end
end
