#
#
#
module ImageService
  
  #
  #
  #
  def self.getExternalImage(obj, use)
    # obj.external_images.use(use)[0]
    cndStr = "imageable_type = ? AND imageable_id = ? AND external_images.use = ?"

    conditions = [cndStr, obj.class.name, obj.id, use]
    
    ExternalImage.all :conditions => conditions
  end
  
private

#select * from external_images where imageable_type = "PublishedProgrammeItem"
#and external_images.use = 'largecard'
#and imageable_id = 87;

  
end