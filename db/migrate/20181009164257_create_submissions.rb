class CreateSubmissions < ActiveRecord::Migration[5.2]

  def change
    create_table :submissions do |t|
      t.decimal :grade

      #Can't seem to figure out how to do files, so commented out for now.
      #t.File :submission_zip

      t.timestamps
    end
  end
end
