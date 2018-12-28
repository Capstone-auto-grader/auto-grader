class MoveGradesIntoSubmissions < ActiveRecord::Migration[5.2]
  def change
    drop_table :grades

    add_column :submissions, :ta_grade, :decimal
    add_column :submissions, :ta_id, :integer
    add_column :submissions, :ta_comment, :text

    remove_column :submissions, :grade_id
  end
end
