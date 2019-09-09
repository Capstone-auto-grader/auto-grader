class User < ApplicationRecord
    attr_accessor :reset_token
    has_many :t_as_class
    has_many :teaches_class
    has_many :taships, through: :t_as_class, source: :course
    has_many :professorships, through: :teaches_class, source: :course
    has_many :ta_assignments, class_name: 'Submission', foreign_key: :ta_id
    has_many :conflicts, class_name: 'TaConflict'
    has_many :conflict_students, through: :conflicts
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
        puts UserMailer.smtp_settings
        UserMailer.password_reset(self).deliver_now
    end
    def send_invite_email
        self.reset_token = User.new_token
        update_attribute(:reset_digest, User.digest(reset_token))
        update_attribute(:reset_sent_at, Time.zone.now)
        update_attribute(:init_password_valid, true)
        UserMailer.welcome_email(self).deliver_now
    end
    def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end
    #Returns true if a password reset has expired.
    def password_reset_expired?
        reset_sent_at < 2.hours.ago
    end

    def welcome_password_expired?
        reset_sent_at < 1.week.ago
    end
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                   BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end
    def User.new_token
        SecureRandom.urlsafe_base64
    end
end
