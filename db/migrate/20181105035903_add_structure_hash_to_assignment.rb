class AddStructureHashToAssignment < ActiveRecord::Migration[5.2]
  def change
    add_column :assignments, :structure, :text
  end
end
