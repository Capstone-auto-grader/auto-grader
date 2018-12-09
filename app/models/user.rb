class User < ApplicationRecord
    attr_accessor :reset_token
    has_many :takes_class
    has_many :t_as_class
    has_many :teaches_class
    has_many :registrations, through: :takes_class, source: :course
    has_many :taships, through: :t_as_class, source: :course
    has_many :professorships, through: :teaches_class, source: :course
    has_many :submissions
    has_many :ta_assignments, class_name: 'Grade', foreign_key: :ta_id
    has_many :assignment_grades, class_name: 'Grade', foreign_key: :student_id
    has_many :ta_conflicts
    has_many :conflicts, through: :ta_conflicts
    before_save { self.email = email.downcase }
    validates :name,  presence: true, length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                       format: { with: VALID_EMAIL_REGEX },
                       uniqueness: { case_sensitive: false }
    has_secure_password

    #Sets password reset attributes
    def create_reset_digest
        self.reset_token = User.new_token
        update_attribute(:reset_digest, User.digest(reset_token))
        update_attribute(:reset_sent_at, Time.zone.now)
    end

    #Sends password reset email
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end

    #Returns true if a password reset has expired.
    def password_reset_expired?
        reset_sent_at < 2.hours.ago
    end
end
