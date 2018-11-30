class CreateGrades < ActiveRecord::Migration[5.2]
  def change
    create_table :grades do |t|
      t.decimal :grade

      t.timestamps
    end
  end
end
