# encoding: utf-8

class BioPictureUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave   # Use cloudinary as the image store

  #
  # Use a combination of the person's name for the id of the image
  #
  def public_id
    publicid = SITE_CONFIG[:conference][:name] + '/'
    publicid += model.person.first_name ? model.person.first_name : ''
    publicid += model.person.last_name ? model.person.last_name : ''
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
