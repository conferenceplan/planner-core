class TimeSlot < ActiveRecord::Base

  audited :allow_mass_assignment => true
  has_many :room_item_assignments
  has_many :rooms, :through => :room_item_assignments #, :source_type => 'Room'
  has_many :programme_items, :through => :room_item_assignments #, :source_type => 'ProgrammeItem'

end
