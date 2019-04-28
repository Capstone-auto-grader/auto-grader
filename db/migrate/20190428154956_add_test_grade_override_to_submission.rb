class AddTestGradeOverrideToSubmission < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :test_grade_override, :decimal
  end
end
