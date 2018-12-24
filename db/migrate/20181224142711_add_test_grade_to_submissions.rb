class AddTestGradeToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :assignments, :test_grade_weight, :integer

    remove_column :submissions, :grade
    add_column :submissions, :test_grade, :decimal

    add_column :grades, :custom_comment, :text
  end
end
