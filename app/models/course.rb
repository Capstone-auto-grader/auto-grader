class Course < ApplicationRecord
    has_many :takes_class
    has_many :t_as_class
    has_many :teaches_class
    has_many :students, through: :takes_class
    has_many :tas, through: :t_as_class, source: :user
    has_many :professors, through: :teaches_class, source: :user
    has_many :assignments

    validates :s3_bucket, presence: true, format: { with: /(?=^.{3,63}$)(?!^(\d+\.)+\d+$)(^(([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])\.)*([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])$)/}
end
