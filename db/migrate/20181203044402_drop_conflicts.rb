class DropConflicts < ActiveRecord::Migration[5.2]
  def change
    drop_table :ta_conflicts
  end
end
