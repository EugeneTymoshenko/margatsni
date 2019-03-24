class Image < ApplicationRecord
  mount_uploader :file_data, ImageUploader

  belongs_to :imageable, polymorphic: true
end
