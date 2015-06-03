module ProgramPlannerHelper
  
  #
  def addItemToRoomAndTime(item, room, day, time)
    # Calculate a delta for the case when daylight savings changes
    start_offset = Time.zone.parse(SiteConfig.first.start_date.to_s).to_datetime.in_time_zone.utc_offset
    item_offset = time.in_time_zone.utc_offset
    delta = (start_offset - item_offset)/60

    assignment = nil
    itemStartTime = time + delta.minutes
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
      candidate.time_slot.destroy
      candidate.destroy
    end
  end
  
end
