class AddIsValidToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :is_valid, :boolean
  end
end
