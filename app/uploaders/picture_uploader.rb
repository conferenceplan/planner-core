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
  version :large_card do
    process :largeCard
  end
  
  version :medium_card do
    process :mediumCard
  end
  
  def largeCard
    width = model.scale ? 368 * model.scale : 368
    height = model.scale ? 128 * model.scale : 128
    return :width => width, :height => height, :crop => :fill, :fetch_format => :png
  end
  
  def mediumCard
    width = model.scale ? 130 * model.scale : 130
    height = model.scale ? 130 * model.scale : 130
    return :width => width, :height => height, :crop => :fill, :fetch_format => :png
  end
  #
  #
  #
  version :bio_list do
    process :bioList
  end
  
  version :bio_detail do
    process :bioDetail
  end
  
  def bioList
    width = model.scale ? 60 * model.scale : 60
    height = model.scale ? 60 * model.scale : 60
    return :height => height, :width => width, :crop => :fill, :gravity => :face, :radius => :max, :fetch_format => :png
  end
  
  def bioDetail
    width = model.scale ? 100 * model.scale : 100
    height = model.scale ? 100 * model.scale : 100
    return :height => height, :width => width, :crop => :fill, :gravity => :face, :fetch_format => :png
  end
  
  #
  #
  #
  version :standard do
    transform = [{:fetch_format => :png}]
    cloudinary_transformation :transformation => transform
  end

end
