class ExternalImage < ActiveRecord::Base
  attr_accessible :picture
  
  mount_uploader :picture, PictureUploader # Use Carrierwave to manage image uploads and retreival (external storage with name in the db)
  
  belongs_to :imageable, polymorphic: true
end
