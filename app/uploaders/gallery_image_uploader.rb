# encoding: utf-8

class GalleryImageUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave   # Use cloudinary as the image store
  include UploaderHelper
  
  # We want a name for the gallery at cloudinary
  # and we will also use the convention name
  def public_id
    publicid = (common_root_path && !model.global) ? root_path + '/' : ''
    publicid += model.gallery ? model.gallery : 'gallery' # use a default gallery if none has been specified
    publicid += '/' + model.filename
    publicid.gsub(/[?!&\s+]/, '')
  end

  #
  #
  #
  version :standard do
    transform = [{:fetch_format => :jpg}]
    cloudinary_transformation :transformation => transform
  end

  #
  # Get a thumbnail of the image
  #
  version :thumbnail do
    transform = [{:width => 200, :crop => :scale},
                                {:fetch_format => :jpg}]
    cloudinary_transformation :transformation => transform
  end

end
