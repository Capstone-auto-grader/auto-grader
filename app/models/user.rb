class User < ApplicationRecord
    has_many :takes_class
    has_many :t_as_class
    has_many :teaches_class
    has_many :registrations, through: :takes_class, source: :course
    has_many :taships, through: :t_as_class, source: :course
    has_many :professorships, through: :teaches_class, source: :course
    has_many :submissions
    before_save { self.email = email.downcase }
    validates :name,  presence: true, length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                       format: { with: VALID_EMAIL_REGEX },
                       uniqueness: { case_sensitive: false }
    has_secure_password
    validates :password, presence: true, length: { minimum: 6 }
end
