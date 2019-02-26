class Post < ApplicationRecord
  belongs_to :user
  has_many :images, as: :imageable
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable
end
