# frozen_string_literal: true

class ImageUploader < CarrierWave::Uploader::Base
  storage :fog

  def store_dir
    "#{Rails.env}/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def size_range
    0..5.megabytes
  end

  def extension_whitelist
    %w[jpg jpeg gif png]
  end
end
