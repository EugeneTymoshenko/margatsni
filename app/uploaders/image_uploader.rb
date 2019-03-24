# frozen_string_literal: true

class ImageUploader < CarrierWave::Uploader::Base
  storage :dropbox

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  def size_range
    0..5.megabytes
  end

  def extension_whitelist
    %w[jpg jpeg gif png]
  end
end
