class CreateStudents < ActiveRecord::Migration[5.2]
  def change
    create_table :students do |t|
      t.string :name
      t.string :email

      t.timestamps
    end

    remove_column :submissions, :user_id
    add_column :submissions, :student_id, :integer

    remove_column :takes_classes, :user_id
    add_column :takes_classes, :student_id, :integer
  end
end
