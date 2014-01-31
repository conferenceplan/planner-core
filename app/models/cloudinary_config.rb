class CloudinaryConfig < ActiveRecord::Base
  attr_accessible :api_key, :api_secret, :cloud_name, :enhance_image_tag, :static_image_support
end
