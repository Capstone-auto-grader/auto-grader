class AddGradeReceivedToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :grade_received, :boolean
    add_column :submissions, :extra_credit_points, :integer

    remove_column :submissions, :test_grade
  end
end
