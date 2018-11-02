class AddAssignmentAndUserRefToSubmission < ActiveRecord::Migration[5.2]
  def change
    add_reference :submissions, :courses, index: true
    add_reference :submissions, :users, index: true
  end
end
