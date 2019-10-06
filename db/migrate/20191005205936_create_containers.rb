class CreateContainers < ActiveRecord::Migration[5.2]
  def change
    drop_table :containers
    remove_column :assignments, :container_name
    create_table :containers do |t|
      t.string :name
      t.string :s3_uri

      t.timestamps
    end
  end
end
