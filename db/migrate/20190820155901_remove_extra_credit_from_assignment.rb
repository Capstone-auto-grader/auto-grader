class RemoveExtraCreditFromAssignment < ActiveRecord::Migration[5.2]
  def change
    remove_column :assignments, :extra_credit
    remove_column :submissions, :extra_credit_points
  end
end
