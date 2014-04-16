#
#
#
class PublishedTimeSlot < ActiveRecord::Base
  attr_accessible :lock_version, :start, :end

  audited :allow_mass_assignment => true
  
  has_many :published_room_item_assignments
  has_many :published_rooms, :through => :published_room_item_assignments
  has_many :published_programme_items, :through => :published_room_item_assignments
  
end
