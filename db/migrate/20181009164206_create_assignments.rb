class CreateAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :assignments do |t|
      t.file, :assignment_tests
      t.date :due_date

      t.timestamps
    end
  end
end
