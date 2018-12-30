class AddResubmitIdToAssignments < ActiveRecord::Migration[5.2]
  def change
    add_column :assignments, :resubmit_id, :integer, optional: true
    add_column :submissions, :resubmission_id, :integer, optional: true

    remove_column :assignments, :due_date
    remove_column :assignments, :description
  end
end
