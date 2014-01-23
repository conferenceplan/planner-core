#
#
#
module PublishedProgramItemsService
  
  #
  #
  #
  def self.findProgramItemsForPerson(person)
    PublishedProgrammeItemAssignment.all(
        :conditions => ['(programme_item_assignments.person_id = ?) AND (programme_item_assignments.role_id in (?))', 
            person.id, 
            [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id,PersonItemRole['Invisible'].id]],
            :include => {:published_programme_item => [{:published_programme_item_assignments => {:person => [:pseudonym, :email_addresses]}}, {:published_room => :published_venue}, :published_time_slot]},
            :order => "published_time_slots.start asc"
    )
  end
  
  #
  #
  #
  def self.getUpdates(pubDate)
    
    deletedItemIds  = getDeletedPublishedProgrammeItems pubDate
    newItemIds      = getNewPublishedProgrammeItems(pubDate).delete_if{ |i| deletedItemIds.include? i } # remove any new that were also deleted in the same period
    updatedItemIds  = getUpdatedPublishedProgrammeItems(pubDate, newItemIds, deletedItemIds)
    
    peopleUpdates   = getUpdatedPeople pubDate
    
    # TODO - we also need to get updates to people such as BIOs and URLs
    # TODO - we also need to get updates to items when a room or venue is renamed...
    
    {
      :new_items      => newItemIds,
      :deleted_items  => deletedItemIds,
      :updated_items  => updatedItemIds,
      :updatedPeople  => peopleUpdates[:updatedPeople],
      :removedPeople  => peopleUpdates[:removedPeople]
    }
  end
  
  
  def self.getNewPublishedProgrammeItems(pubDate)
    
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItem') AND (audits.action = 'create')", pubDate.timestamp]
      
    audits.collect { |a| a.auditable_id } # do by id?
    
  end
  
  def self.getDeletedPublishedProgrammeItems(pubDate)
    
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItem') AND (audits.action = 'destroy')", pubDate.timestamp]
      
    # audits.collect { |a| PublishedProgrammeItem.find(a.auditable_id) }
    audits.collect { |a| a.auditable_id } # do by id?
    
  end
  
  #
  # new items - new PublishedProgrammeItem
  # updated items - PublishedRoomItemAssignment, and PublishedProgrammeItemAssignment, and PublishedProgrammeItem (also PublishedTimeSlot)
  # deleted items - delete PublishedProgrammeItem
  #
  def self.getUpdatedPublishedProgrammeItems(pubDate, new_items = [], deleted_items = [])
    
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItem') AND (audits.action = 'update')", pubDate.timestamp]
      
    updated = audits.collect { |a| a.auditable_id }
    
    # removed from room and time (check to see if the item is still published)
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedRoomItemAssignment') AND (audits.action = 'destroy')", pubDate.timestamp]
    updated = updated.concat audits.collect {|a| a.audited_changes['published_programme_item_id'] } # also get a list of the roomitemassignment ids and use that to filter the subsequent collections
    
    # assigned to a room and time
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedRoomItemAssignment') AND (audits.action = 'create')", pubDate.timestamp]
    updated = updated.concat audits.collect {|a| a.audited_changes['published_programme_item_id'] }

    # room and/or time changed
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedRoomItemAssignment') AND (audits.action = 'update')", pubDate.timestamp]
      # go through the assigment to get to the actual item ... and make sure they were not subsequentally deleted
    updated = updated.concat audits.collect {|a| (PublishedRoomItemAssignment.exists? a.auditable_id) ? PublishedRoomItemAssignment.find(a.auditable_id).published_programme_item_id : nil }.compact
      
    # People added
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItemAssignment') AND (audits.action = 'create')", pubDate.timestamp]
    updated = updated.concat audits.collect {|a| a.audited_changes['published_programme_item_id'] }
      
    # People removed
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItemAssignment') AND (audits.action = 'destroy')", pubDate.timestamp]
    updated = updated.concat audits.collect {|a| a.audited_changes['published_programme_item_id'] }
    
    # People role changed
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItemAssignment') AND (audits.action = 'update')", pubDate.timestamp]
    updated = updated.concat audits.collect {|a| (PublishedProgrammeItemAssignment.exists? a.auditable_id) ? PublishedProgrammeItemAssignment.find(a.auditable_id).published_programme_item_id : nil }.compact
      
    updated.uniq.delete_if{ |i| new_items.include? i }.delete_if{ |i| deleted_items.include? i }
  end
  
  # new people - PublishedProgrammeItemAssignment
  # updated people - PublishedProgrammeItemAssignment
  # deleted people - PublishedProgrammeItemAssignment
  #
  def self.getUpdatedPeople(pubDate)
    # People added or updated
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItemAssignment') AND (audits.action = 'create')", pubDate.timestamp]
    updateOrAdded = audits.collect {|a| a.audited_changes['person_id'] }
      
    # People role changed, could be from reserved to participant or vice-versa
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItemAssignment') AND (audits.action = 'update')", pubDate.timestamp]
    updateOrAdded = updateOrAdded.concat audits.collect {|a| (PublishedProgrammeItemAssignment.exists? a.auditable_id) ? PublishedProgrammeItemAssignment.find(a.auditable_id).person_id : nil}.compact

    updateOrAdded = updateOrAdded.collect {|i| (Person.find(i).publishedProgrammeItemAssignments.size > 0) ? i : nil }.compact

    # People removed - we only want to know who no longer has any items assigned to them, otherwise these are updated people (i.e. removed from an item)
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItemAssignment') AND (audits.action = 'destroy')", pubDate.timestamp]
    removed = audits.collect {|a| (Person.find(a.audited_changes['person_id']).publishedProgrammeItemAssignments.size == 0) ? a.audited_changes['person_id'] : nil }.compact
    
    { :updatedPeople => updateOrAdded, :removedPeople => removed }
  end
  
  #
  # ===========================================================================================================
  #
  
  #
  #
  #
  def self.getUpdatesFromPublishDate(pubDate)
    resultantChanges = {}

    audits = Audited::Adapters::ActiveRecord::Audit.all(
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like ?)", pubDate.timestamp, 'Published%'],
      :order => "audits.created_at asc"
    )
        
    # item, action, person, as role
    audits.each do |audit|
      if audit.action == 'destroy' # item removed
        # when an item is removed there are multiple entries in the audit table. PublishedProgrammeItemAssignment, PublishedRoomItemAssignment, PublishedTimeSlot, PublishedProgrammeItem
        # all for the one event. We need to be able to infer that this is one event and not mony...
        # All are destroy events... but we only need to know the one i.e. the programme item was destroyed
        if audit.auditable_type == "PublishedProgrammeItem"
          title = audit.audited_changes['title']
          id = audit.auditable_id
          # need to know what the time was ....
          resultantChanges = addPinkSheetEntryWithKey(resultantChanges, id , :removeItem , :title, title) # TODO - add other values from the audit table provide more info i.e. dropped from day & time
        elsif audit.auditable_type == "PublishedProgrammeItemAssignment" # person was removed...
            if PublishedProgrammeItem.exists? audit.audited_changes["published_programme_item_id"]
              programmeItem = PublishedProgrammeItem.find(audit.audited_changes["published_programme_item_id"]) # this will fail
            else
              programmeItem = nil
            end
            person = Person.find(audit.audited_changes["person_id"])
            if person.publishedProgrammeItemAssignments.size == 0
              role = PersonItemRole[audit.audited_changes["role_id"]]
              # resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :removePerson, person, role)
              # TODO - need to make sure person is removed does not have any prog items
              resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :detailUpdate, programmeItem)
            end
        elsif audit.auditable_type == 'PublishedRoomItemAssignment'
          begin
          id = audit.audited_changes['published_programme_item_id']
          room = PublishedRoom.find(audit.audited_changes['published_room_id'])
          timeAudit = Audit.all(
            :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like ?) AND (audits.auditable_id = ?)", 
              pubDate.timestamp, 'PublishedTimeSlot%', audit.audited_changes['published_time_slot_id']]
          )
          resultantChanges = addPinkSheetEntryWithKey(resultantChanges, id, :removeItem, :info, room, timeAudit[0].audited_changes['start'])
          rescue
            # do nowt, kuldge to get round assigment destroys where programme item does not exist
          end
        end # we are ignoring the destroys of the room item assignment and the timeslot... TODO - collect for information on the prog item
      else  
        if audit.auditable_type == "PublishedProgrammeItemAssignment" # person added or removed
          resultantChanges = getPeopleChange(audit, resultantChanges)
        elsif audit.auditable_type == "PublishedRoomItemAssignment" # item added, or moved
          resultantChanges = getItemChange(audit, resultantChanges, pubDate)
        end
      end
    end

    return resultantChanges
  end
  
  def self.getProgrammeItemChanges(id, pubDate)
    audits = Audited::Adapters::ActiveRecord::Audit.all(
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like ?) AND (audits.auditable_id = ?)", pubDate.timestamp, 'PublishedProgrammeItem', id],
      :order => "audits.created_at asc"
    )
    
    return audits
  end
  
  def self.getPeopleChange(auditInfo, resultantChanges)
    # Get the programme item assignments that have changed - this is the set of people
    if auditInfo.audited_changes["published_programme_item_id"] # Add person
      begin
      programmeItem = PublishedProgrammeItem.find(auditInfo.audited_changes["published_programme_item_id"])
      role = PersonItemRole[auditInfo.audited_changes["role_id"]]
      person = Person.find(auditInfo.audited_changes["person_id"])
      resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :addPerson, person, role) # TODO - change for update if not new person
      
      # TODO - the item was also changed...
      resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :detailUpdate, programmeItem)

      rescue  
      end
    else
      if auditInfo.audited_changes["role_id"].kind_of?(Array) # then we have a role change
        newrole = PersonItemRole[auditInfo.audited_changes["role_id"][1]]
        assignment = PublishedProgrammeItemAssignment.find(auditInfo.auditable_id)
        programmeItem = assignment.published_programme_item
        person = assignment.person
        if newrole != PersonItemRole['Reserved'] && newrole != PersonItemRole['Invisible']
          oldrole = PersonItemRole[auditInfo.audited_changes["role_id"][0]]
          resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :newRole, person, oldrole, newrole)
        else
          # TODO - check if we actual get here
          # resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :removePerson, person)
          resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :detailUpdate, programmeItem)
        end
      else 
      end
    end

    return resultantChanges
  end

  def self.getItemChange(auditInfo, resultantChanges, pubDate)
    begin
    programmeItemAssignment = PublishedRoomItemAssignment.find(auditInfo.auditable_id) # get the associated program item assignment
    programmeItem = programmeItemAssignment.published_programme_item # from that we can get the program item
    oldtime = nil
    if auditInfo.audited_changes["published_time_slot_id"] # if it is a change to the time slot then we report on that
      # the time slot has changed if we have an array of changed time information and that array contains more than one value      
      movedTime = auditInfo.audited_changes["published_time_slot_id"].kind_of?(Array) && auditInfo.audited_changes["published_time_slot_id"].size > 1
      
      if movedTime # Item X has been rescheduled from time A to time B
          oldtime = PublishedTimeSlot.find(auditInfo.audited_changes["published_time_slot_id"][0]) if PublishedTimeSlot.exists? auditInfo.audited_changes["published_time_slot_id"][0]
          newtime = PublishedTimeSlot.find(auditInfo.audited_changes["published_time_slot_id"][1])
      else #
        if PublishedTimeSlot.exists? auditInfo.audited_changes["published_time_slot_id"]
          newtime = PublishedTimeSlot.find(auditInfo.audited_changes["published_time_slot_id"])
        else
          newtime = programmeItem.published_time_slot
        end
      end
      
      if movedTime #&& newtime.start != oldtime.start # then we have move time slot
        # Item X has been rescheduled from time A to time B
        if oldtime
          resultantChanges = addPinkSheetEntryWithKey(resultantChanges, programmeItem, :update, :timeMove, oldtime.start, newtime.start)
        else
          resultantChanges = addPinkSheetEntryWithKey(resultantChanges, programmeItem, :update, :timeMove, nil, newtime.start)
        end
      else # we have moved room or added an item
        # TODO - could also be a change to one of the other attributes
        if resultantChanges[:update] && resultantChanges[:update][programmeItem]
          resultantChanges = addPinkSheetEntryWithKey(resultantChanges, programmeItem, :update, :add, newtime.start)
        end
          # If the item was update (Title etc) then it is not a new....
          # Look for the PublishedProgrammeItem and see if it is an update
          if (auditInfo.action == 'update')
            auditChange = getProgrammeItemChanges(programmeItem.id, pubDate);
            if auditChange
              auditChange.each do |a|
                resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :detailUpdate, a.audited_changes)
              end
            end
          else  
            resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :new, newtime.start)
          end
        # Item X has been added to room B at time C
      end
    else # The item has been moved to a new venue
      # else it is an addition of the program item to the schedule
      # Item X has been added or moved to the program in room A at time B
      room = nil
      fromRoom = nil
      if auditInfo.audited_changes['published_room_id']
        if auditInfo.audited_changes['published_room_id'].kind_of?(Array)
          fromRoom = PublishedRoom.find(auditInfo.audited_changes["published_room_id"][0])
          room = PublishedRoom.find(auditInfo.audited_changes["published_room_id"][1])
        else
          room = PublishedRoom.find(auditInfo.audited_changes["published_room_id"])
        end
      end
      resultantChanges = addPinkSheetEntryWithKey(resultantChanges, programmeItem, :update, :roomMove, room, fromRoom)
    end
    # TODO - if we have a move + add of the same item then it is a move not an add
    
    rescue
    end
    return resultantChanges
  end
  
  # Person add
  # Person roleChange
  # Person remove
  #
  # action => { programmeItem => [] }
  #
  # { programmeItem => [action, action, action] }
  # action == {'timeMove' => [from, to]}
  # action == {'roomMove' => to}
  # action == 'add'
  #
  def self.addPinkSheetEntry(resultCollection, programmeItem, operation, *args)
    begin
    if resultCollection[operation]
      if resultCollection[operation][programmeItem]
        resultCollection[operation][programmeItem].concat args
      else
        resultCollection[operation][programmeItem] = args
      end
    else
      resultCollection[operation] = {programmeItem => args}
    end
    
    rescue  
    end
    return resultCollection
  end
  
  def self.addPinkSheetEntryWithKey(resultCollection, programmeItem, operation, key, *args)
    
    if resultCollection[operation]
      if resultCollection[operation][programmeItem]
        resultCollection[operation][programmeItem][key] = args
      else
        resultCollection[operation][programmeItem] = { key => args }
      end
    else
      resultCollection[operation] = {programmeItem => {key => args}}
    end
    
    return resultCollection
  end

  
end
