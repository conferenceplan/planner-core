
module Planner
  module ImageUrlGenerator

    def self.person_image img, scale: 1, version: :standard
      url = ENV['G_DEFAULT_PERSON_IMAGE_URL'] #start with default grenadine person image url. This will get replaced by the others if the correct conditions are met
      if img.present?
        img.scale = scale
        image = img.bio_picture.send(version)
        
        if image && image.url
          url = get_image_url(image, img.lock_version)
        end
        # if the person has an image, use that image
      elsif !DefaultBioImage.first.nil?
        img = DefaultBioImage.first
        img.scale = scale
        image = img.image.send(version)
        
        if image && image.url
          url = get_image_url(image, img.lock_version)
        end
        # if there is no person image but there is a default image, use that one
      end
      
      url
    end

    # Most of these methods are included here because their twins in various ControllerAdditions.rb files are inaccessible from this module
    
    def self.base_image_url
      #
      # Arguments: none
      # Returns: url (String) containing the Grenadine CDN image base url from PlannerCore's application.yml file
      #
      eval(ENV[:base_image_url.to_s])
    end
    
    def self.get_image_url img, version = nil
      #
      # Arguments: img (BioPictureUploader::Uploader)
      # Returns: url (String) pointing to the an image's grenadine cdn url for cloudinary images
      #
      if version
        url = base_image_url + img.url(version: version).partition(/upload/)[2]
      else
        url = base_image_url + img.url.partition(/upload/)[2]
      end
      
      url
    end

  end
end
