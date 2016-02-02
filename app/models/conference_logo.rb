class ConferenceLogo < ActiveRecord::Base
  attr_accessible :lock_version, :image
  attr_accessor :scale

  mount_uploader :image, LogoUploader # Use Carrierwave to manage image uploads and retrieval (external storage with name in the db)
end
