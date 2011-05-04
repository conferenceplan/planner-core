class RoomItemAssignment < ActiveRecord::Base
  acts_as_audited

  belongs_to :room
  belongs_to :programme_item
  belongs_to :time_slot
end
