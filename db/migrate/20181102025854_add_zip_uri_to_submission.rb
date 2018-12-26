class AddZipUriToSubmission < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :zip_uri, :string
  end
end
