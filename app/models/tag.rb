class Tag < ApplicationRecord
  has_and_belongs_to_many :posts, dependent: :destroy

  scope :search_by_name, ->(query) { where('name LIKE ?', "%#{query}%").order(name: :asc) }
end
