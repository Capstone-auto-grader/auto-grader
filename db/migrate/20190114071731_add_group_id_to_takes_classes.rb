class AddGroupIdToTakesClasses < ActiveRecord::Migration[5.2]
  def change
    add_column :takes_classes, :group, :integer
    add_column :assignments, :group_offset, :integer
  end
end
