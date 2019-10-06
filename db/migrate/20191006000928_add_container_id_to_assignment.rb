class AddContainerIdToAssignment < ActiveRecord::Migration[5.2]
  def change
    add_column :assignments, :container_id, :integer
  end
end
