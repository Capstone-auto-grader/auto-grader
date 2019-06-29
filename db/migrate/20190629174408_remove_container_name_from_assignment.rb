class RemoveContainerNameFromAssignment < ActiveRecord::Migration[5.2]
  def change
    remove_column :assignments, :container_name
  end
end
