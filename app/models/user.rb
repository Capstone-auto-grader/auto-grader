class User < ApplicationRecord
    has_many :takes_class
    has_many :t_as_class
    has_many :teaches_class
    has_many :registrations, through: :takes_class, source: :course
    has_many :taships, through: :t_as_class, source: :course
    has_many :professorships, through: :teaches_class, source: :course
    has_many :submissions
end
