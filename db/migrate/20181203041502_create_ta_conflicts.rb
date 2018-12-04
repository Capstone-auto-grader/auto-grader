class CreateTaConflicts < ActiveRecord::Migration[5.2]
  def change
    create_table :ta_conflicts do |t|
      t.timestamps
      t.integer :user_id
      t.integer :student_id
    end
  end
end
