class AddHasTestsToAssignment < ActiveRecord::Migration[5.2]
  def change
    add_column :assignments, :has_tests, :boolean
  end
end
