class AddDescriptionToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :assignments, :description, :text
  end
end
