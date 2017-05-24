module ProgramPlannerHelper
  
  #
  def addItemToRoomAndTime(item, room, day, time)
    assignment = nil
    itemStartTime = time
    itemEndTime = itemStartTime + item.duration.minute

    RoomItemAssignment.transaction do # ensure that all the changes are done within the one transaction
      # 1. Figure out where the item is going to be placed
      newTimeSlot = TimeSlot.new(:start => itemStartTime, :end => itemEndTime)
      newTimeSlot.save
      
      # update the assignment ...
      if item.room_item_assignment != nil 
        assignment = item.room_item_assignment
        old_time_slot = assignment.time_slot
        
        assignment.room = room
        assignment.time_slot = newTimeSlot
        assignment.day = day
        
        old_time_slot.delete
      else
        # Create the new assignment
        assignment = RoomItemAssignment.new(:room => room, :time_slot => newTimeSlot, :day => day, :programme_item => item)
      end
      
      # check the children
      item.children.each do |child|
        child_off_and_duration = child.duration + child.start_offset
        if child_off_and_duration > item.duration
          # Then there is a problem
          # Try to keep the duration
          # first change the offset
          potential_offset = child.start_offset - 
                                (child_off_and_duration - item.duration)
          if potential_offset >= 0
            child.start_offset = potential_offset
          else
            child.start_offset = 0
            child.duration = item.duration if child.duration > item.duration
          end
          
          child.save
        end
      end
      
      assignment.save
    end
    
    return assignment
  end

  def removeAssignment(candidate)
    RoomItemAssignment.transaction do
      # 1. Unassociate a room with the program item i.e. remove the program item from the association
      candidate.destroy
    end
  end
  
end
