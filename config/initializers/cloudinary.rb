#
# Get these values from the database (assuming that there are values in the db)
#
# NOTE: to prevent this from loading when doing a rake db:migrate use NODAEMON=1 rake db:migrate
#
unless ENV['NODAEMON']
  # cfg = CloudinaryConfig.find :first # for now we only have one convention... change when we have many (TODO)
  # Cloudinary.config do |config|
    # config.cloud_name           = cfg ? cfg.cloud_name : ''
    # config.api_key              = cfg ? cfg.api_key : ''
    # config.api_secret           = cfg ? cfg.api_secret : ''
    # config.enhance_image_tag    = cfg ? cfg.enhance_image_tag : false
    # config.static_image_support = cfg ? cfg.static_image_support : false
  #  config.cdn_subdomain = true
  end
end
