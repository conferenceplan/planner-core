class PendingPublicationItem < ActiveRecord::Base
  attr_accessible :lock_version, :programme_item_id
  
  belongs_to  :programme_item
end
