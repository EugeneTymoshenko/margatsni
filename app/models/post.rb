class Post < ApplicationRecord
  belongs_to :user

  has_one :image, as: :imageable, dependent: :destroy

  has_many :likes, as: :likeable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  has_and_belongs_to_many :tags, dependent: :destroy

  accepts_nested_attributes_for :image

  after_create :create_tags

  before_update :update_tags

  def update_tags
    post = Post.find_by(id: id)
    post.tags.clear
    extract_name_tags.each do |name|
      tag = Tag.find_or_create_by(name: name)
      post.tags << tag
    end
  end

  def create_tags
    post = Post.find_by(id: id)
    extract_name_tags.each do |name|
      tag = Tag.find_or_create_by(name: name)
      post.tags << tag
    end
  end

  private

  def extract_name_tags
    body.scan(/#\w+/).uniq.map { |name| name.downcase.delete('#') }
  end
end
