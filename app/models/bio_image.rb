class BioImage < ActiveRecord::Base
  attr_accessible :lock_version, :bio_picture, :bio_picture_cache, :person_id
  attr_accessor :scale

  mount_uploader :bio_picture, BioPictureUploader # Use Carrierwave to manage image uploads and retreival (external storage with name in the db)

  belongs_to :person

  audited except: :bio_picture, :associated_with => :person

  def public_image_url scale: 1, version: :standard
    Planner::ImageUrlGenerator.person_image(
      self, scale: scale, version: version
    )
  end
  
  # on destroy need to touch the person attached to ???
  before_destroy :touch_person
  
  private
  
  def touch_person
    if person
      person.touch
      person.save
    end
  end

end
