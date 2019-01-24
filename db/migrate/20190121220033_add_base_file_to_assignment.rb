class AddBaseFileToAssignment < ActiveRecord::Migration[5.2]
  def change
    add_column :assignments, :base_uri, :text
  end
end
