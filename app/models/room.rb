class Room < ActiveRecord::Base
  
  belongs_to  :venue
  
  # this is a many to many
  has_many :room_item_assignments do
    def day(d) # get the room item assignments for the given day if the day parameter is used
      find(:all, :conditions => ['day = ?', d])
    end
  end
  has_many :programme_items, :through => :room_item_assignments # through the room item assignment
  has_many :time_slots, :through => :room_item_assignments #, :source_type => 'TimeSlot'

  acts_as_audited :parent => :venue

  def removeAllTimes()
    self.room_item_assignments.each do |ts|
      TimeSlot.delete(ts.time_slot_id)
      RoomItemAssignment.delete(ts.id)
    end
  end

end
