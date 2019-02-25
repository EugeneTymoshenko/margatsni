class Comment < ApplicationRecord
  belongs_to user
  has_many :images, as: :entity
  has_many :likes, as: :entity
  has_many :comments, as: :entity
  belongs_to :entity, polymorphic: true
end
