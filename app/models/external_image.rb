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

  def public_image_url opts = {}
    self.scale = opts[:scale] if opts[:scale].present?
    url = ""
    image = nil

    if opts[:version].present?
      image = picture.send opts[:version].to_sym
    else
      image = picture.send use
    end

    url = image.url if image.present?

    url = eval(ENV[:base_image_url.to_s]) + url.partition(/upload/)[2] if url.present? && eval(ENV[:base_image_url.to_s]).present?

    url
  end
end
