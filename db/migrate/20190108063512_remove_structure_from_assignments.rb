class RemoveStructureFromAssignments < ActiveRecord::Migration[5.2]
  def change
    remove_column :assignments, :structure
  end
end
