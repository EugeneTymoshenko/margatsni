class Image < ApplicationRecord
  belongs_to :entity, polymorphic: true
end
