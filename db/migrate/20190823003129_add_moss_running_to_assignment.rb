class AddMossRunningToAssignment < ActiveRecord::Migration[5.2]
  def change
    add_column :assignments, :moss_running, :boolean
  end
end
