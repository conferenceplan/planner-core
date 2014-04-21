#
#
#
class PublishedRoomItemAssignment < ActiveRecord::Base
  attr_accessible :lock_version, :day, :published_programme_item_id, :published_room_id, :published_time_slot_id,
                  :published_room, :published_time_slot, :published_programme_item

  audited :allow_mass_assignment => true

  belongs_to :published_room
  belongs_to :published_programme_item
  belongs_to :published_time_slot, :dependent => :destroy
end
