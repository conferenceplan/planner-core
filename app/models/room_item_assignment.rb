class RoomItemAssignment < ActiveRecord::Base
  attr_accessible :lock_version, :day, :room, :programme_item, :time_slot
  audited :allow_mass_assignment => true

  belongs_to :room
  belongs_to :programme_item
  belongs_to :time_slot, :dependent => :destroy
end
