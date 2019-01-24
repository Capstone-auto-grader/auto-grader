class AddMossUrlToAssignment < ActiveRecord::Migration[5.2]
  def change
    add_column :assignments, :moss_url, :text
  end
end
