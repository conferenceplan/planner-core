class ExternalImage < ActiveRecord::Base
  attr_accessible :lock_version, :picture, :use, :imageable_id, :imageable_type
  attr_accessor :scale
  audited except: :picture
  
  mount_uploader :picture, PictureUploader # Use Carrierwave to manage image uploads and retreival (external storage with name in the db)

  belongs_to :imageable, polymorphic: true # so we can have many different model types that reference an external image

  validates_inclusion_of :use, :in => [:largecard, :mediumcard, :logo, :sponsor, :biodefault] # restrict the values that can be used for the image use
  
  before_destroy :update_imageable_timestamp
  
  def update_imageable_timestamp
    self.imageable.id_will_change!
    self.imageable.save!
  end

  def use
    read_attribute(:use).to_sym
  end

  def use= (value)
    write_attribute(:use, value.to_s)
  end
end
