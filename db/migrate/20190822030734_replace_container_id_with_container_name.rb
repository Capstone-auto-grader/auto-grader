class ReplaceContainerIdWithContainerName < ActiveRecord::Migration[5.2]
  def change
    remove_column :assignments, :container_id
    add_column :assignments, :container_name, :string
  end
end
