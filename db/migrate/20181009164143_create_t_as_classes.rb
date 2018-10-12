class CreateTAsClasses < ActiveRecord::Migration[5.2]
  def change
    create_table :t_as_classes do |t|
      t.integer :user_id
      t.integer :course_id
      t.timestamps
    end
  end
end
