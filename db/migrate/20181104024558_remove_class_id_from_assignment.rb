class RemoveClassIdFromAssignment < ActiveRecord::Migration[5.2]
  def change
    remove_column :assignments, :class_id
  end
end
