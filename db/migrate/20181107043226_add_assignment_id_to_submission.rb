class AddAssignmentIdToSubmission < ActiveRecord::Migration[5.2]
  def change
    add_reference :submissions, :assignment, index: true
  end
end
