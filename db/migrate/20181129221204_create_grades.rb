class CreateGrades < ActiveRecord::Migration[5.2]
  def change
    create_table :grades do |t|
      t.integer :student_id
      t.integer :ta_id
      t.integer :assignment_id

      t.timestamps
    end
  end
end
