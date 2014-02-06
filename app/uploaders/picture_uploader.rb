# encoding: utf-8

class PictureUploader < CarrierWave::Uploader::Base

  include Cloudinary::CarrierWave   # Use cloudinary as the image store

  # process :convert => 'png'         # convert all images to PNG
  # process :tags => ['planner_pic']  # default tag for the "uploaded" image
  
  #
  # Get a thumbnail of the image
  #
  version :thumbnail do
    resize_to_fit(50, 50)
  end
  
  #
  #
  #
  version :standard do
    process :resize_to_fill => [100, 150, :north] # TODO - verify that this is what we want to use
  end

end
