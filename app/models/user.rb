class User < ApplicationRecord
  authenticates_with_sorcery!
  EMAIL_REGEXP = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/.freeze

  has_one :role, dependent: :destroy
  has_one :image, as: :imageable, dependent: :destroy

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :follower_users, dependent: :destroy, foreign_key: :follower_id
  has_many :following_users, dependent: :destroy, class_name: 'FollowerUser'

  has_many :followers, through: :follower_users, source: :user, class_name: 'User'
  has_many :following, through: :following_users, source: :follower, class_name: 'User'

  scope :sea, -> { where("username LIKE ?", "%#{params[:username]}%") }

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }, on: :create
  validates :email, uniqueness: { case_sensitive: false }, format: { with: EMAIL_REGEXP,
                                                                     message: 'is invalid' }

  accepts_nested_attributes_for :image

  before_create :build_role, on: :create, unless: :role
end
