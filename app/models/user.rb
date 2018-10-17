class User < ApplicationRecord
    has_many :takes_class
    has_many :t_as_for
    has_many :teaches_class
    has_many :registrations, through: :takes_class, source: :courses
    has_many :taships, through: :t_as_class, source: :courses
    has_many :professorships, through: :teaches_class, source: :courses
    # has_many courses, through: :t_as_for
    # has_many courses, through: :teaches_class
end
