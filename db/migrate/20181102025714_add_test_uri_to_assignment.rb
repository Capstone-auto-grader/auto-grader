class AddTestUriToAssignment < ActiveRecord::Migration[5.2]
  def change
    add_column :assignments, :test_uri, :text
  end
end
