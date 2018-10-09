class CreateTeachesClasses < ActiveRecord::Migration[5.2]
  def change
    create_table :teaches_classes do |t|

      t.timestamps
    end
  end
end
