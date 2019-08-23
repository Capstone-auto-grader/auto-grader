class AddHasResubmissionToAssignment < ActiveRecord::Migration[5.2]
  def change
    add_column :assignments, :has_resubmission, :boolean
  end
end
