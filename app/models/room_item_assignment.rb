class RoomItemAssignment < ActiveRecord::Base
  attr_accessible :lock_version, :day, :room, :programme_item, :time_slot
  audited :allow_mass_assignment => true

  belongs_to :room
  belongs_to :programme_item
  belongs_to :time_slot, :dependent => :destroy
end

# TODO - add flag in here to make it a time block i.e. across all rooms for the conference - RECESS
# time blocks will show in the grid in each of the rooms (also on sites)
# person can not reschedule from the grid
# Need the ability to put this into the published as well
# In the mobile app it will be an "intervel/recess" (need to pick a name)
