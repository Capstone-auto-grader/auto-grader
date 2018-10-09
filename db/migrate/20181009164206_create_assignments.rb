class CreateAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :assignments do |t|      
      
      #Can't seem to figure out how to do files, so commented out for now.
      #t.File, :assignmentTests
      
      t.date :dueDate

      t.timestamps
    end
  end
end
