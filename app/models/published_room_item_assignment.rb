#
#
#
class PublishedRoomItemAssignment < ActiveRecord::Base
  acts_as_audited

  belongs_to :published_room
  belongs_to :published_programme_item
  belongs_to :published_time_slot, :dependent => :destroy
end
