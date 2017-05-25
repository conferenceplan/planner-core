# encoding: utf-8

class PictureUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave   # Use cloudinary as the image store
  include UploaderHelper

  def stored_version
    self.model.lock_version
  end

  #
  #
  #
  def public_id
    publicid = root_path + '/'
    publicid += model.imageable_type ? model.imageable_type : ''
    publicid += model.imageable_id ? ('_' + model.imageable_id.to_s) : ''
    publicid += model.use ? ('_' + model.use.to_s) : ''
    publicid.gsub(/[?!&\s+]/, '')
  end

  def largeCard
    width = ((model.scale && model.scale > 0) ? 368 * model.scale : 368).to_i
    height = ((model.scale && model.scale > 0) ? 132 * model.scale : 132).to_i
    return :width => width, :height => height, :crop => :pad, :fetch_format => :jpg
  end

  def mediumCard
    width = ((model.scale && model.scale > 0) ? 130 * model.scale : 130).to_i
    height = ((model.scale && model.scale > 0) ? 130 * model.scale : 130).to_i
    return :width => width, :height => height, :crop => :pad, :fetch_format => :jpg
  end

  def bioList
    width = ((model.scale && model.scale > 0) ? 60 * model.scale : 60).to_i
    height = ((model.scale && model.scale > 0) ? 60 * model.scale : 60).to_i
    return :height => height, :width => width, :crop => :fill, :gravity => :face, :radius => :max, :fetch_format => :jpg
  end

  def bioDetail
    width = ((model.scale && model.scale > 0) ? 100 * model.scale : 100).to_i
    height = ((model.scale && model.scale > 0) ? 100 * model.scale : 100).to_i
    return :height => height, :width => width, :crop => :fill, :gravity => :face, :fetch_format => :jpg
  end



  # Image versions
  version :thumbnail do
    transform = [{:width => 200, :crop => :scale},
                                {:fetch_format => :jpg}]
    cloudinary_transformation :transformation => transform
  end

  version :bio_list do
    process :bioList
  end

  version :bio_detail do
    process :bioDetail
  end

  version :large_card do
    process :largeCard
  end

  version :medium_card do
    process :mediumCard
  end

  version :standard do
    transform = [{:fetch_format => :jpg}]
    cloudinary_transformation :transformation => transform
  end


  # Versions that can be dynamically dispatched from the image's "use" attribute

  version :biodefault do
    process :bioDetail
  end

  version :largecard do
    process :largeCard
  end

  version :mediumcard do
    process :mediumCard
  end
end
