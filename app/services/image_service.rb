#
#
#
module ImageService
  
  #
  #
  #
  def self.getExternalImage(obj, use)
    ExternalImage.where(["imageable_type = ? AND imageable_id = ? AND external_images.use = ?", obj.class.name, obj.id, use])
  end
  
end