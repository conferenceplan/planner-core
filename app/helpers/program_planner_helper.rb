module ProgramPlannerHelper
  
  def addItemToRoomAndTime(item, room, day, time)
    assignment = nil
    times = time.split(':') # hours and minutes
    itemStartTime = Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + day.to_i.days + times[0].to_i.hours + times[1].to_i.minutes
    itemEndTime = itemStartTime + item.duration.minute
    
    RoomItemAssignment.transaction do # ensure that all the changes are done within the one transaction
      # 1. Figure out where the item is going to be placed
      newTimeSlot = TimeSlot.new(:start => itemStartTime, :end => itemEndTime)
      newTimeSlot.save
      
      if item.room_item_assignment != nil 
        removeAssignment(item.room_item_assignment)
      end
      
      # Create the new assignment
      assignment = RoomItemAssignment.new(:room => room, :time_slot => newTimeSlot, :day => day, :programme_item => item)
      assignment.save
    end
    
    return assignment
  end

  def removeAssignment(candidate)
    RoomItemAssignment.transaction do
      # 1. Unassociate a room with the program item i.e. remove the program item from the association
      candidate.time_slot.delete
      candidate.delete
    end
  end
  
end
