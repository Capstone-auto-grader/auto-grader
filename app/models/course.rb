class Course < ApplicationRecord
    has_many :takes_class
    has_many :t_as_for
    has_many :teaches_class
    has_many :students, through: :takes_class, class_name: 'User'
    has_many :tas, through: :t_as_for, class_name: 'User'
    has_many :professors, through: :teaches_class, class_name: 'User'
    has_many :assignments
end
