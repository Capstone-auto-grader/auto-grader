class AddFailuresColumnToSubmission < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :failures, :text
  end
end
