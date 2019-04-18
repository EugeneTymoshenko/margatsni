class Post < ApplicationRecord
  belongs_to :user

  has_one :image, as: :imageable, dependent: :destroy

  has_many :likes, as: :likeable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  has_and_belongs_to_many :tags, dependent: :destroy

  accepts_nested_attributes_for :image

  before_save :create_tags, if: :body_changed?

  def create_tags
    tags.clear
    extract_name_tags.each do |name|
      tag = Tag.find_or_create_by(name: name)
      tags << tag
    end
  end

  private

  def extract_name_tags
    body.scan(/#\w+/).uniq.map { |name| name.downcase.delete('#') }
  end
end
