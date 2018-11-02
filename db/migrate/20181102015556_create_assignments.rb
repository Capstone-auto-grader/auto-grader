class CreateAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :assignments do |t|
      t.integer :class_id
      t.string :name
      t.string :assignment_test
      t.date :due_date

      t.timestamps
    end
  end
end
