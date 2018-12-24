class RemoveCourseFromSubmissions < ActiveRecord::Migration[5.2]
  def change
    remove_column :submissions, :course_id, :bigint
    remove_column :submissions, :failures

    remove_column :grades, :grade
  end
end
