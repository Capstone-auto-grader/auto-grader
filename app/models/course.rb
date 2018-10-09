class Course < ApplicationRecord
    has_many :takes_class
    has_many :t_as_for
    has_many :teaches_class
    has_many :users, through: :takes_class
    has_many :users, through: :t_as_for
    has_many :users, through: :teaches_class
    has_many :assignments
end
