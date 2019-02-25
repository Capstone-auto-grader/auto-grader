class AddContainerNameToAssignment < ActiveRecord::Migration[5.2]
  def change
    add_column :assignments, :container_name, :string
  end
end
