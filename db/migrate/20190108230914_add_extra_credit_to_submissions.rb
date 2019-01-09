class AddExtraCreditToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :extra_credit_points, :decimal

    add_column :assignments, :extra_credit, :text
  end
end
