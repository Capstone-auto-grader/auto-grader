class AddTaGrade < ActiveRecord::Migration[5.2]
  def change
    add_column :grades, :ta_grade, :decimal
  end
end
