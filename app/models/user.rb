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

  scope :search_by_username, -> (query) { where('username ILIKE ?', "%#{query}%").order(username: :asc) }

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }, on: :create
  validates :email, uniqueness: { case_sensitive: false }, format: { with: EMAIL_REGEXP,
                                                                     message: 'is invalid' }

  accepts_nested_attributes_for :image

  before_create :build_role, on: :create, unless: :role
  before_create :confirmation_token

  def email_activate
    self.email_confirmed = true
    self.confirm_token = nil
    save
  end

  private

  def confirmation_token
    loop do
      self.confirm_token = SecureRandom.urlsafe_base64
      break unless User.where(confirm_token: confirm_token).exists?
    end
  end
end
