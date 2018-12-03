class RecreateTaConflicts < ActiveRecord::Migration[5.2]
  def change
    create_table :ta_conflicts do |t|
      t.timestamps
      t.references :user, index: true, foreign_key: true
      t.references :student, index: true
    end
  end
end
