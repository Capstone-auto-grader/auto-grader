class AddSecHashToSubmission < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :security_hash, :text
  end
end
