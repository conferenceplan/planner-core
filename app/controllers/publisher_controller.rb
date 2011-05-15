#
#
#
class PublisherController < PlannerController
  def index
  end
  
  # publish the selected program items
  def publish
    # Copy the selected program items into the published table    
  end
  
  # list all the published programme items
  def list
  end
  
  private
  
  def copyProgrammeItems()
    # Get the items for publish
    ProgrammeItem srcItems = ProgrammeItem.all # TODO - change to get only the published (and changed)
    
    # TODO - wrap this in a transaction (block)
    srcItems.each do |srcItem|
      # check for existence of already published item and if it is there then use that
      newItem = (srcItem.published == nil) ? PublishedProgrammeItem.new : srcItem.published
      
      # copy the details from the unpublished item to the new
      newItem = copy(srcItem, newItem)
      newItem.original = srcItem # this create the Publication record as well to tie the two together
      
      # link to the people (and their roles)
      copyAssignments(srcItem, newItem)
      
      newRoom = publishRoom(srcItem.room)
      if newItem.published_room_item_assignment
        newItem.published_time_slot.delete if newItem.published_time_slot != nil # if we are changing time slot then clean up the old one
        newTimeSlot = copy(srcItem.time_slot, PublishedTimeSlot.new) 
        
        newItem.published_room = newRoom
        newItem.published_time_slot = newTimeSlot
      else
        newTimeSlot = copy(srcItem.time_slot, PublishedTimeSlot.new)
        newItem.published_room_item_assignment.create(:published_room => newRoom, :published_time_slot => newTimeSlot)
      end
      
      # TODO - we need to copy the tags...
      
      # TODO - we will need the venues as well
      
      # Put the date and the person who did the publish into the association (Publication)
      newItem.publication.publication_date = DateTime.current
      newItem.publication.user = @current_user
      newItem.save
    end
  end
  
  def publishRoom(srcRoom)
    # 1. find out if the room is already published
    pubRoom = srcRoom.published
    
    # 2. if not then publish it
    if ! pubRoom
      pubRoom = copy(srcRoom, PublishedRoom.new)
      pubRoom.original = srcRoom
    end
    
    return pubRoom
  end
  
  # Copy the assignments of people form the unpublished item to the published item
  def copyAssignments(src, dest)
    src.programme_item_assignments do |srcAssignment|
      # add the person only if the destination does not have that person
      if (dest.people == nil) || (dest.people.index(srcAssignment.person) == nil)
        dest.published_programme_item_assignments.new(:person => srcAssignment.person, :role => srcAssignment.role)
      else # the destination has the person, but their role may have changed
        # find the index of the person only if the role is also different
        idx = dest.published_programme_item_assignments.index{ |a| (a.person == srcAssignment.person) && (a.role != srcAssignment.role) }
        dest[idx].role = srcAssignment.role if idx != nil
      end
    end
  end
  
  # copy the attributes from the source that have an equivalent in the destination
  def copy(src, dest)
    src.attributes.each do |name, val|
      # but do not copy any of the variables needed for the optimistic locking, the id, etc
      if (dest.attributes.key? name) && (["lock_version", "created_at", "updated_at", "id"].index(name) == nil)
        # TODO - only copy values that have changed?
        dest.write_attribute name , val
      end
    end
    
    return dest
  end
  
end
