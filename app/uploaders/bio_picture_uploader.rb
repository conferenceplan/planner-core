# encoding: utf-8

class BioPictureUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave   # Use cloudinary as the image store

  #
  # Use a combination of the person's name for the id of the image
  #
  def public_id
    publicid = SITE_CONFIG[:conference][:name] + '/'
    if (model.person)
      publicid += model.person.first_name ? model.person.first_name : ''
      publicid += model.person.last_name ? model.person.last_name : ''
    else
      publicid += 'default_bio_image'
    end
    publicid.gsub(/\s+/, "")
  end
  
  #
  # Get a thumbnail of the image
  #
  version :thumbnail do
    transform = [{:height => 100, :width => 100, :crop => :fill, :gravity => :face},
                                {:fetch_format => :png}]
    cloudinary_transformation :transformation => transform
  end
  
  #
  #
  #
  version :standard do
    transform = [{:height => 200, :width => 200, :crop => :fill, :gravity => :face},
                                {:fetch_format => :png}]
    cloudinary_transformation :transformation => transform
  end
  
  #
  #
  #
  version :list do
    process :bioList
  end
  
  version :detail do
    process :bioDetail
  end
  
  def bioList
    width = ((model.scale && model.scale > 0) ? 60 * model.scale : 60).to_i
    height = ((model.scale && model.scale > 0) ? 60 * model.scale : 60).to_i
    return :height => height, :width => width, :crop => :fill, :gravity => :face, :radius => :max, :fetch_format => :png
  end
  
  def bioDetail
    width = ((model.scale && model.scale > 0) ? 100 * model.scale : 100).to_i
    height = ((model.scale && model.scale > 0) ? 100 * model.scale : 100).to_i
    return :height => height, :width => width, :crop => :fill, :gravity => :face, :fetch_format => :png
  end
  
  #
  #
  #
  version :circle do
    transform = [{:height => 200, :width => 200, :crop => :fill, :gravity => :face, :radius => :max},
                                {:fetch_format => :png}]
    cloudinary_transformation :transformation => transform
  end
  
  #
  #
  #
  version :grayscale do
    transform = [{:height => 200, :width => 200, :crop => :fill, :gravity => :face}, 
                                {:effect => :grayscale}, {:fetch_format => :png}]
    cloudinary_transformation :transformation => transform
  end
  
  #
  #
  #
  version :grayscale_circle do
    transform = [{:height => 200, :width => 200, :crop => :fill, :gravity => :face, :radius => :max}, 
                                {:effect => :grayscale}, {:fetch_format => :png}]
    cloudinary_transformation :transformation => transform
  end
  
end
