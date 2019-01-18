class CreateSubmissionBatches < ActiveRecord::Migration[5.2]
  def change
    create_table :submission_batches do |t|
      t.references :assignment, foreign_key: true
      t.references :user, foreign_key: true
      t.string :zip_uri
      t.timestamps
    end
  end
end
