class User < ApplicationRecord
  authenticates_with_sorcery!
  EMAIL_REGEXP = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/.freeze

  validates :username, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, on: :create
  validates :email, uniqueness: true, format: { with: EMAIL_REGEXP,
                                                message: 'is invalid' }
end
