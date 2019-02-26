class Comment < ApplicationRecord
  belongs_to user
  belongs_to :entity, polymorphic: true
  has_many :images, as: :imageable
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable
end
