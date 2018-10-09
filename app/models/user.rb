class User < ApplicationRecord
    has_many :takes_class
    has_many :t_as_for
    has_many :teaches_class
    has_many courses, through: :takes_class
    has_many courses, through: :t_as_for
    has_many courses, through: :teaches_class
end
