class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :username, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, on: :create
  validates :email, uniqueness: true, format: { with: /\A[^@\s]+@[^@\s]+\z/,
                                                message: 'is invalid' }
end
