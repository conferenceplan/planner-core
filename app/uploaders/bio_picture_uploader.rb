# encoding: utf-8

class BioPictureUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave   # Use cloudinary as the image store
  include UploaderHelper
  
  SALT = "This is a Bio Pic"

  def stored_version
    self.model.lock_version
  end
  
  #
  # Use a combination of the person's name for the id of the image
  #
  def public_id
    publicid = common_root_path + '/'
    
    if model.is_a?(SurveyResponse)
      details = model.survey_respondent_detail
      if details
        hasher = Hashids.new(SALT, 4)
        publicid += hasher.encode(details.id)
        publicid += "_"
      else
        publicid += 'response'
      end
      publicid += '_' + model.id.to_s
    else  
      if ((defined? model.person) && model.person)
        hasher = Hashids.new(SALT, 4)
        publicid += hasher.encode(model.person.id)
        publicid += '_' + model.person.id.to_s
      else
        publicid += 'default_bio_image'
        publicid += '_' + model.id.to_s
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
  version :full do
    process :fullSize
  end

  #
  #
  #
  version :list do
    process :bioList
  end
  
  version :square256 do
    process :bioSquare256
  end
  
  version :detail do
    process :bioDetail
  end
  
  #
  #
  #
  def bioList
    width = ((model.scale && model.scale > 0) ? 120 * model.scale : 120).to_i
    height = ((model.scale && model.scale > 0) ? 120 * model.scale : 120).to_i
    return :height => height, :width => width, :crop => :fill, 
      :gravity => :face, :radius => :max, :fetch_format => :jpg,
      :version => 33
  end
  
  def bioDetail
    width = ((model.scale && model.scale > 0) ? 368 * model.scale : 368).to_i
    height = ((model.scale && model.scale > 0) ? 368 * model.scale : 368).to_i
    return :height => height, :width => width, :crop => :fill, :gravity => :face, :fetch_format => :jpg
  end
  
  def standardImage
    width = ((model.scale && model.scale > 0) ? 736 * model.scale : 736).to_i
    height = ((model.scale && model.scale > 0) ? 736 * model.scale : 736).to_i
    return :height => height, :width => width, :crop => :fill, :gravity => :face, :fetch_format => :jpg
  end
  
  def bioSquare256
    width = 256
    height = 256
    return :height => height, :width => width, :crop => :fill, :gravity => :face, :fetch_format => :jpg
  end
  
  def fullSize
    return :fetch_format => :jpg
  end
  
end
