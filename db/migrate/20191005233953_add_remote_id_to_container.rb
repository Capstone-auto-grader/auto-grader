class AddRemoteIdToContainer < ActiveRecord::Migration[5.2]
  def change
    add_column :containers, :remote_id, :string
  end
end
