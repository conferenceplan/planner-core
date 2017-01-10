#
#
#
module ConfigService
  
  #
  #
  #
  def self.hasCloudinaryConfig?
    cloud_config = CloudinaryConfig.first

    cloud_config && cloud_config.api_key != nil && !cloud_config.api_key.empty?
  end

end
