#
#
#
class PublisherController < PlannerController
  include TagUtils
  
  def index
  end
  
  # publish the selected program items
  def publish
    @newItems = 0
    @modifiedItems = 0
    @renmovedItems = 0
    p = PublicationDate.new
    p.timestamp = DateTime.current
    @newItems = copyProgrammeItems(getNewProgramItems()) # copy all unpublished programme items
    @modifiedItems = copyProgrammeItems(getModifiedProgramItems()) # copy all programme items that have changes made (room assignment, added person, details etc)
    @removedItems = unPublish(getRemovedProgramItems()) # remove all items that should no longer be published
    @removedItems += unPublish(getUnpublishedItems()) # remove all items that should no longer be published
    p.save
    render :layout => 'content'
  end
  
  # list all the published programme items
  def list
  end
  
  private
  
  # Select from publications and room item assignments items where published_id is not in the room item assignments items
  def getNewProgramItems
    clause = addClause(nil,'print = ?',true) # only get those that are marked for print
    clause = addClause(clause,'programme_items.id not in (select publications.original_id from publications where publications.original_type = ?)', 'ProgrammeItem')
    clause = addClause(clause,'room_item_assignments.id is not null ', nil)
#    clause = addClause(clause,'programme_item_assignments.role_id != ? ', PersonItemRole['Reserved'])
    args = { :conditions => clause, :include => :room_item_assignment } #, :programme_item_assignments] }
    return ProgrammeItem.find :all, args
  end
  
  # Check this for modified items - i.e. what happens if the time is changed?
  # in that case the room item assignment is recreated...
  def getModifiedProgramItems
    clause = addClause(nil,'print = ?',true) # only get those that are marked for print
    clause = addClause(clause,'room_item_assignments.id is not null ', nil)
    clause = addClause(clause,'programme_items.id in (select publications.original_id from publications where publications.original_type = ?)', 'ProgrammeItem')
    clause = addClause(clause,'publications.publication_date < programme_items.updated_at OR publications.publication_date < room_item_assignments.updated_at OR publications.publication_date < programme_item_assignments.updated_at', nil)
    # check the date of the programme item compared with the published
    args = { :conditions => clause, :include => [:room_item_assignment, :programme_item_assignments, :publication] }
    return ProgrammeItem.find :all, args
  end
  
  def getRemovedProgramItems
    # publications with no original or that the published flag is no longer true
    clause = [REMOVE_CLAUSE, 'PublishedProgrammeItem', 'PublishedProgrammeItem']
    args = { :conditions => clause, :include => [:publication] }
    return PublishedProgrammeItem.find :all, args
  end
  
  def getUnpublishedItems
    clause = [UNPUBLISH_CLAUSE, 'ProgrammeItem', false]
    args = { :conditions => clause }
    return PublishedProgrammeItem.find :all, args
  end

REMOVE_CLAUSE = <<"EOS"
  published_programme_items.id in (
  select publications.published_id from publications 
  LEFT OUTER JOIN room_item_assignments on publications.original_id = room_item_assignments.programme_item_id 
  WHERE publications.published_type like ? AND room_item_assignments.id is null)
  OR
  published_programme_items.id not in (
  select published_id from publications where publications.published_type =  ?)
EOS

UNPUBLISH_CLAUSE = <<"EOS"
  published_programme_items.id in (select publications.published_id from programme_items 
  left join publications on publications.original_id = programme_items.id and publications.original_type = ?
  where print = ? 
  and publications.published_id is not null)
EOS
    
  def getRemovedParticipants
    # Select from publications and programme item assignments where published_id is not in the programme item assignments
  end
  
  def unPublish(pubItems)
    nbrProcessed = 0
    PublishedProgrammeItem.transaction do
      pubItems.each do |item|
        item.destroy
        nbrProcessed += 1
      end
    end
    return nbrProcessed
  end
  
  def copyProgrammeItems(srcItems)
    nbrProcessed = 0
    PublishedProgrammeItem.transaction do
      srcItems.each do |srcItem|
        # check for existence of already published item and if it is there then use that
        newItem = (srcItem.published == nil) ? PublishedProgrammeItem.new : srcItem.published
        
        # copy the details from the unpublished item to the new
        newItem = copy(srcItem, newItem)
        newItem.original = srcItem # this create the Publication record as well to tie the two together
        # Need to copy the tags...
        copyTags(srcItem, newItem, 'PrimaryArea')
        
        newItem.save

        # link to the people (and their roles)
        updateAssignments(srcItem, newItem)
        
        newRoom = publishRoom(srcItem.room)
        if newItem.published_room_item_assignment
          newItem.published_room = newRoom if newItem.published_room != newRoom # change the room if necessary
          
          # Only need to copy time if the new time slot is more recent than the published
          if newItem.published_time_slot != nil
            if srcItem.time_slot.updated_at > newItem.published_time_slot.updated_at
              newItem.published_time_slot.delete # if we are changing time slot then clean up the old one
              newTimeSlot = copy(srcItem.time_slot, PublishedTimeSlot.new) 
              newTimeSlot.save
              newItem.published_time_slot = newTimeSlot
              newItem.save
              logger.info "Moved item times"
            end
          else
              newTimeSlot = copy(srcItem.time_slot, PublishedTimeSlot.new) 
              newTimeSlot.save
              newItem.published_time_slot = newTimeSlot
              newItem.save
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
        nbrProcessed += 1
      end
    end
    return nbrProcessed
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
  
  #
  # Update the assignments of people from the unpublished item to the published item
  #
  def updateAssignments(src, dest)
    if src.programme_item_assignments
      src.programme_item_assignments.each do |srcAssignment|
        # add the person only if the destination does not have that person
        if (dest.people == nil) || (dest.people.index(srcAssignment.person) == nil)
          # check their role for reserved, if reserved then we do not want that person published
          if (srcAssignment.role != PersonItemRole['Reserved'] )
            assignment = dest.published_programme_item_assignments.new(:person => srcAssignment.person, :role => srcAssignment.role)
            assignment.save
          end
        else # the destination has the person, but their role may have changed
          # find the index of the person only if the role is also different
          idx = dest.published_programme_item_assignments.index{ |a| (a.person == srcAssignment.person) && (a.role != srcAssignment.role) }
          if idx != nil
            dest.published_programme_item_assignments[idx].role = srcAssignment.role
            dest.published_programme_item_assignments[idx].save
            # TODO - if the role is changed to reserved then they should be removed...
          end
        end
      end
      
      # if the destination has a person that the source does not then we need to remove that assignment
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
  
  #
  # Copy the attributes from the source that have an equivalent in the destination
  #
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
