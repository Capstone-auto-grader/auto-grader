class TaConflict < ApplicationRecord
  belongs_to :user
  belongs_to :conflict, class_name: 'User'
end
