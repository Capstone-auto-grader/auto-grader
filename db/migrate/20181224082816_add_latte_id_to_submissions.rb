class AddLatteIdToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :latte_id, :integer
    add_index :submissions, :latte_id

    add_column :submissions, :tests_passed, :integer
    add_column :submissions, :total_tests, :integer
  end
end
