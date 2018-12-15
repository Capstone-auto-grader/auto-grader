class AddGradeToSubmission < ActiveRecord::Migration[5.2]
  def change
    add_reference :submissions, :grade, index: true
  end
end
