class AddOverridesToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :final_grade_override, :decimal
    add_column :submissions, :late_penalty, :integer
    add_column :submissions, :comment_override, :text

    add_column :assignments, :submitted_once, :boolean
  end
end
