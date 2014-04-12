# encoding: utf-8

class LogoUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave   # Use cloudinary as the image store

  #
  # Use a combination of the person's name for the id of the image
  #
  def public_id
    publicid = SITE_CONFIG[:conference][:name] + '/'
    publicid += 'conf_logo'
    publicid.gsub(/\s+/, "")
  end
  
  #
  #
  #
  version :standard do
    process :standardImage
  end
  
  #
  #
  #
  def standardImage
    width = ((model.scale && model.scale > 0) ? 240 * model.scale : 240).to_i
    height = ((model.scale && model.scale > 0) ? 100 * model.scale : 100).to_i
    return :height => height, :width => width, :crop => :fill, :fetch_format => :jpg
  end
  
end
