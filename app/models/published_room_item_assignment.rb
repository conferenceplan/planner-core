#
#
#
class PublishedRoomItemAssignment < ActiveRecord::Base
  audited :allow_mass_assignment => true

  belongs_to :published_room
  belongs_to :published_programme_item
  belongs_to :published_time_slot, :dependent => :destroy
end
