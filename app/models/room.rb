class Room < ActiveRecord::Base
  
  belongs_to  :venue
  
  # this is a many to many
  has_many :room_item_assignments
  has_many :programme_items, :through => :room_item_assignments # through the room item assignment
  has_many :time_slots, :through => :room_item_assignments #, :source_type => 'TimeSlot'
  # Question - how can I get the times for a given day from the assigned_time_slots? and sort it by room?

  acts_as_audited :parent => :venue

  def removeAllTimes()
    self.room_item_assignments.each do |ts|
      TimeSlot.delete(ts.time_slot_id)
      RoomItemAssignment.delete(ts.id)
    end
  end

end
