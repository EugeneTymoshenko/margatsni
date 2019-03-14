class Post < ApplicationRecord
  belongs_to :user

  has_one :image, as: :imageable, dependent: :destroy

  has_many :likes, as: :likeable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  accepts_nested_attributes_for :image
end
