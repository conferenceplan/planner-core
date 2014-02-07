# encoding: utf-8

class PictureUploader < CarrierWave::Uploader::Base

  include Cloudinary::CarrierWave   # Use cloudinary as the image store

  #
  #
  #
  def public_id
    publicid = SITE_CONFIG[:conference][:name] + '/'
    publicid += model.imageable_type ? model.imageable_type : ''
    publicid += model.imageable_id ? ('_' + model.imageable_id.to_s) : ''
    publicid += model.use ? ('_' + model.use.to_s) : ''
    publicid.gsub(/\s+/, "")
  end
  
  #
  # Get a thumbnail of the image
  #
  version :thumbnail do
    transform = [{:width => 200, :crop => :scale},
                                {:fetch_format => :png}]
    cloudinary_transformation :transformation => transform
  end
  
  #
  #
  #
  version :standard do
    transform = [{:fetch_format => :png}]
    cloudinary_transformation :transformation => transform
  end

end
