class CreateTAsClasses < ActiveRecord::Migration[5.2]
  def change
    create_table :t_as_classes do |t|

      t.timestamps
    end
  end
end
