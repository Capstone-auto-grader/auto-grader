class AddAttachmentToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :attachment, :string
  end
end
