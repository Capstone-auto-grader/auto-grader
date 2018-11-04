class ModifyRelations < ActiveRecord::Migration[5.2]
  def change
    remove_reference :assignments, :courses, index: true
    add_reference :assignments, :course, index: true
    remove_reference :submissions, :courses, index: true
    add_reference :submissions, :course, index: true
    remove_reference :submissions, :users,  index: true
    add_reference :submissions, :user, index: true
  end
end
