class RoomItemAssignment < ActiveRecord::Base
  belongs_to :room
  belongs_to :programme_item
  belongs_to :time_slot
end
