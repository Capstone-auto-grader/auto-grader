class CreateTakesClasses < ActiveRecord::Migration[5.2]
  def change
    create_table :takes_classes do |t|
      t.integer :user_id
      t.integer :course_id
      t.timestamps
    end
  end
end
