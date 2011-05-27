#
#
#
#
# TODO - create a change log for the publications - link to published programme item and have a timestamped list of what has changed...
#
class PublisherController < PlannerController
  include TagUtils
  
  def index
  end
  
  # publish the selected program items
  def publish
    # TODO - report on the number of programme items published etc
    copyProgrammeItems(getNewProgramItems()) # copy all unpublished programme items
    copyProgrammeItems(getModifiedProgramItems()) # copy all programme items that have changes made (room assignment, added person, details etc)
    # Get a list of all objects that have been deleted (assignments, items etc)
    unPublish(getRemovedProgramItems())
  end
  
  # list all the published programme items
  def list
  end
  
  private
  
  # Select from publications and room item assignments items where published_id is not in the room item assignments items
  def getNewProgramItems
    clause = addClause(nil,'print = ?',true) # only get those that are marked for print
    clause = addClause(clause,'programme_items.id not in (select publications.original_id from publications where publications.original_type = "ProgrammeItem")', nil)
    clause = addClause(clause,'room_item_assignments.id is not null ', nil)
    args = { :conditions => clause, :include => [:room_item_assignment, :programme_item_assignments] }
    return ProgrammeItem.find :all, args
  end
  
  def getModifiedProgramItems
    clause = addClause(nil,'print = ?',true) # only get those that are marked for print
    clause = addClause(clause,'room_item_assignments.id is not null ', nil)
    clause = addClause(clause,'programme_items.id in (select publications.original_id from publications where publications.original_type = "ProgrammeItem")', nil)
    clause = addClause(clause,'publications.publication_date < programme_items.updated_at OR publications.publication_date < room_item_assignments.updated_at OR publications.publication_date < programme_item_assignments.updated_at', nil)
    # check the date of the programme item compared with the published
    args = { :conditions => clause, :include => [:room_item_assignment, :programme_item_assignments, :publication] }
    return ProgrammeItem.find :all, args
  end
  
  # Select from publications and room item assignments items where published_id is not in the room item assignments items
  def getRemovedProgramItems
    # publications with no original or that the published flag is no longer true
    clause = addClause(nil,'published_programme_items.id not in (select publications.published_id from publications where publications.published_type = "PublishedProgrammeItem")', nil)
    args = { :conditions => clause, :include => [:publication] }
    return PublishedProgrammeItem.find :all, args
  end
  
  def getRemovedParticipants
    # Select from publications and programme item assignments where published_id is not in the programme item assignments
  end
  
  def unPublish(pubItems)
    PublishedProgrammeItem.transaction do
      pubItems.each do |item|
        item.destroy
      end
    end
  end
  
  def copyProgrammeItems(srcItems)
    PublishedProgrammeItem.transaction do
      srcItems.each do |srcItem|
        # check for existence of already published item and if it is there then use that
        newItem = (srcItem.published == nil) ? PublishedProgrammeItem.new : srcItem.published
        
        # copy the details from the unpublished item to the new
        newItem = copy(srcItem, newItem)
        newItem.original = srcItem # this create the Publication record as well to tie the two together
 
        # TODO - along with the reason
        newItem.save

        # Need to copy the tags...
        copyTags(srcItem, newItem, 'PrimaryArea')
        
        # link to the people (and their roles)
        copyAssignments(srcItem, newItem)
        
        newRoom = publishRoom(srcItem.room)
        if newItem.published_room_item_assignment
          newItem.published_room = newRoom if newItem.published_room != newRoom # change the room if necessary
          
          # Only need to copy time if the new time slot is more recent than the published
          if newItem.published_time_slot != nil
            if srcItem.time_slot.updated_at > newItem.published_time_slot.updated_at
              newItem.published_time_slot.delete # if we are changing time slot then clean up the old one
              newTimeSlot = copy(srcItem.time_slot, PublishedTimeSlot.new) 
              newItem.published_time_slot = newTimeSlot
            end
          end
        else
          newTimeSlot = copy(srcItem.time_slot, PublishedTimeSlot.new)
          assignment = PublishedRoomItemAssignment.new(:published_room => newRoom, 
                  :published_time_slot => newTimeSlot, 
                  :day => srcItem.room_item_assignment.day, 
                  :published_programme_item => newItem)
          assignment.save
        end

        # Put the date and the person who did the publish into the association (Publication)
        newItem.publication.publication_date = DateTime.current
        newItem.publication.user = @current_user
        newItem.publication.save
      end
    end
  end

  def publishRoom(srcRoom)
    # 1. find out if the room is already published
    pubRoom = srcRoom.published
    
    # 2. if not then publish it
    if ! pubRoom
      pubRoom = copy(srcRoom, PublishedRoom.new)
      pubRoom.original = srcRoom
      pubRoom.publication.publication_date = DateTime.current
      pubRoom.publication.user = @current_user

      # we will need the venues as well
      pubVenue = publishVenue(srcRoom.venue)
      pubRoom.published_venue = pubVenue
    end
    
    return pubRoom
  end
  
  def publishVenue(srcVenue)
    pubVenue = srcVenue.published
    
    if !pubVenue
      pubVenue = copy(srcVenue, PublishedVenue.new)
      pubVenue.original = srcVenue
      pubVenue.publication.publication_date = DateTime.current
      pubVenue.publication.user = @current_user
    end
    
    return pubVenue
  end
  
  # Copy the assignments of people from the unpublished item to the published item
  def copyAssignments(src, dest)
    # TODO - if the destination has a person that the source does not then we need to remove that assignment
    if src.programme_item_assignments
      src.programme_item_assignments.each do |srcAssignment|
        # add the person only if the destination does not have that person
        if (dest.people == nil) || (dest.people.index(srcAssignment.person) == nil)
          assignment = dest.published_programme_item_assignments.new(:person => srcAssignment.person, :role => srcAssignment.role)
          assignment.save
        else # the destination has the person, but their role may have changed
          # find the index of the person only if the role is also different
          idx = dest.published_programme_item_assignments.index{ |a| (a.person == srcAssignment.person) && (a.role != srcAssignment.role) }
          if idx != nil
            dest[idx].role = srcAssignment.role
            dest[idx].save
          end
        end
      end
      
      dest.published_programme_item_assignments.each do |pitem|
        if (src.people.index(pitem.person) == nil)
          pitem.destroy
        end
      end
    else # since there are no source assignments we should then remove all the destination assignments (if there are any)
      if dest.published_programme_item_assignments
        dest.published_programme_item_assignments.destroy
      end
    end
  end
  
  # copy the attributes from the source that have an equivalent in the destination
  def copy(src, dest)
    src.attributes.each do |name, val|
      # but do not copy any of the variables needed for the optimistic locking, the id, etc
      if (dest.attributes.key? name) && (["lock_version", "created_at", "updated_at", "id"].index(name) == nil)
        # Only copy values that have changed?
        dest.write_attribute(name , val) if (dest.attributes[name] == nil) || (dest.attributes[name] != val)
      end
    end
    
    return dest
  end
  
end
