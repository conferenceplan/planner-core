class BioImage < ActiveRecord::Base
  attr_accessible :lock_version, :bio_picture, :bio_picture_cache, :person_id
  attr_accessor :scale

  mount_uploader :bio_picture, BioPictureUploader # Use Carrierwave to manage image uploads and retreival (external storage with name in the db)

  belongs_to :person

  audited except: :bio_picture, :associated_with => :person

  def public_image_url opts = {}
    self.scale = opts[:scale] if opts[:scale].present?
    url = ""
    image = nil

    if opts[:version].present?
      image = bio_picture.send opts[:version].to_sym
    else
      image = bio_picture.standard
    end

    url = image.url if image.present?

    url = eval(ENV[:base_image_url.to_s]) + url.partition(/upload/)[2] if url.present? && eval(ENV[:base_image_url.to_s]).present?

    url
  end

end
