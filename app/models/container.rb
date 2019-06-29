class Container < ApplicationRecord
  validates :name, uniqueness: {case_sensitive: false},
                  format: {with: /([\w]+[-_]?)+/}
  has_many :assignments
end
