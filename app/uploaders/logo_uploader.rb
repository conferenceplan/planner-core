# encoding: utf-8

class LogoUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave   # Use cloudinary as the image store
  include UploaderHelper

  def stored_version
    self.model.lock_version
  end

  #
  # Use a combination of the person's name for the id of the image
  #
  def public_id
    publicid = root_path + '/'
    publicid += 'conf_logo'
    publicid.gsub(/[?!&\s+]/, '')
  end
  
  #
  #
  #
  version :standard do
    process :standardImage
  end
  
  version :full do
    process :fullImage
  end
  
  #
  #
  #
  def fullImage
    return :fetch_format => :jpg
  end
  
  #
  #
  #
  def standardImage
    width = ((model.scale && model.scale > 0) ? 240 * model.scale : 240).to_i
    height = ((model.scale && model.scale > 0) ? 100 * model.scale : 100).to_i
    return :height => height, :width => width, :crop => :fit, :fetch_format => :jpg
  end
  
end
