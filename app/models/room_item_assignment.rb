class RoomItemAssignment < ActiveRecord::Base
  audited :allow_mass_assignment => true

  belongs_to :room
  belongs_to :programme_item
  belongs_to :time_slot
end
