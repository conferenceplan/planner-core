class BioImage < ActiveRecord::Base
  attr_accessible :bio_picture, :bio_picture_cache

  mount_uploader :bio_picture, BioPictureUploader # Use Carrierwave to manage image uploads and retreival (external storage with name in the db)

  belongs_to :person
  
  audited :associated_with => :person

end
