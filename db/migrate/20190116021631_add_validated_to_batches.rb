class AddValidatedToBatches < ActiveRecord::Migration[5.2]
  def change
    add_column :submission_batches, :validated, :boolean
  end
end
