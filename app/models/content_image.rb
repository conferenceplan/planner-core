class ContentImage < ActiveRecord::Base
  attr_accessible :gallery, :picture, :lock_version
  attr_accessor :global, :filename

  mount_uploader :picture, GalleryImageUploader # Use Carrierwave to manage image uploads and retreival

  audited except: :picture
end
