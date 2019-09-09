class AddInitPasswordValidToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :init_password_valid, :boolean
  end
end
