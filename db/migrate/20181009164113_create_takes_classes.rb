class CreateTakesClasses < ActiveRecord::Migration[5.2]
  def change
    create_table :takes_classes do |t|

      t.timestamps
    end
  end
end
