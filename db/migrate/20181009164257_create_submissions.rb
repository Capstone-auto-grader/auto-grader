class CreateSubmissions < ActiveRecord::Migration[5.2]
  def change
    create_table :submissions do |t|
      t.decimal :grade
      t.file :submission_zip

      t.timestamps
    end
  end
end
