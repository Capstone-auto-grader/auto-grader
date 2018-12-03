class DestroyAndRecreateTaConflict < ActiveRecord::Migration[5.2]
  def change
    drop_table :ta_conflicts
    create_table :ta_conflicts do |t|
      t.timestamps
      t.references :user, index: true, foreign_key: true
      t.references :conflict, index: true

    end
    add_foreign_key :ta_conflicts, :users, column: :conflict_id
  end
end
