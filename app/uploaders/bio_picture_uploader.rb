# encoding: utf-8

class BioPictureUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave   # Use cloudinary as the image store
  include UploaderHelper

  #
  # Use a combination of the person's name for the id of the image
  #
  def public_id
    publicid = common_root_path + '/'
    if model.is_a?(SurveyResponse)
      details = model.survey_respondent_detail
      if details
        publicid += details.first_name ? details.first_name : ''
        publicid += details.last_name ? details.last_name : ''
      else
        publicid += 'response'
      end
      publicid += '_' + model.id.to_s
    else  
      if ((defined? model.person) && model.person)
        publicid += model.person.first_name ? model.person.first_name : ''
        publicid += model.person.last_name ? model.person.last_name : ''
      else
        publicid += 'default_bio_image'
      end
    end
      
    publicid.gsub(/[?!&\s+]/, '')
  end
  
  #
  # Get a thumbnail of the image
  #
  version :thumbnail do
    # transform = [{:height => 100, :width => 100, :crop => :fill, :gravity => :face},
                                # {:fetch_format => :jpg}]
    # cloudinary_transformation :transformation => transform
    process :bioDetail
  end
  
  #
  #
  #
  version :standard do
    # transform = [{:height => 200, :width => 200, :crop => :fill, :gravity => :face},
                                # {:fetch_format => :jpg}]
    # cloudinary_transformation :transformation => transform
    process :standardImage
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
  
  #
  #
  #
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
  
  def standardImage
    width = ((model.scale && model.scale > 0) ? 368 * model.scale : 368).to_i
    height = ((model.scale && model.scale > 0) ? 368 * model.scale : 368).to_i
    return :height => height, :width => width, :crop => :fill, :gravity => :face, :fetch_format => :jpg
  end
  
end
