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
  def self.getUpdatesFromPublishDate(pubDate)
    resultantChanges = {}

    audits = Audit.all(
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
          title = audit.changes['title']
          id = audit.auditable_id
          # need to know what the time was ....
          resultantChanges = addPinkSheetEntryWithKey(resultantChanges, id , :removeItem , :title, title) # TODO - add other values from the audit table provide more info i.e. dropped from day & time
        elsif audit.auditable_type == "PublishedProgrammeItemAssignment" # person was removed...
          begin
            programmeItem = PublishedProgrammeItem.find(audit.changes["published_programme_item_id"]) # this will fail
            role = PersonItemRole[audit.changes["role_id"]]
            person = Person.find(audit.changes["person_id"])
            resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :removePerson, person, role)
          rescue
            # do nowt, kuldge to get round assigment destroys where programme item does not exist
          end
        elsif audit.auditable_type == 'PublishedRoomItemAssignment'
          id = audit.changes['published_programme_item_id']
          room = PublishedRoom.find(audit.changes['published_room_id'])
          timeAudit = Audit.all(
            :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like ?) AND (audits.auditable_id = ?)", 
              pubDate.timestamp, 'PublishedTimeSlot%', audit.changes['published_time_slot_id']]
          )
          resultantChanges = addPinkSheetEntryWithKey(resultantChanges, id, :removeItem, :info, room, timeAudit[0].changes['start'])
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
    audits = Audit.all(
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like ?) AND (audits.auditable_id = ?)", pubDate.timestamp, 'PublishedProgrammeItem', id],
      :order => "audits.created_at asc"
    )
    
    return audits
  end
  
  def self.getPeopleChange(auditInfo, resultantChanges)
    # Get the programme item assignments that have changed - this is the set of people
    if auditInfo.changes["published_programme_item_id"] # Add person
      begin
      programmeItem = PublishedProgrammeItem.find(auditInfo.changes["published_programme_item_id"])
      role = PersonItemRole[auditInfo.changes["role_id"]]
      person = Person.find(auditInfo.changes["person_id"])
      resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :addPerson, person, role)
      rescue  
      end
    else
      if auditInfo.changes["role_id"].kind_of?(Array) # then we have a role change
        newrole = PersonItemRole[auditInfo.changes["role_id"][1]]
        assignment = PublishedProgrammeItemAssignment.find(auditInfo.auditable_id)
        programmeItem = assignment.published_programme_item
        person = assignment.person
        if newrole != PersonItemRole['Reserved'] && newrole != PersonItemRole['Invisible']
          oldrole = PersonItemRole[auditInfo.changes["role_id"][0]]
          resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :newRole, person, oldrole, newrole)
        else
          resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :removePerson, person)
        end
      end
    end

    return resultantChanges
  end

  def self.getItemChange(auditInfo, resultantChanges, pubDate)
    begin
    programmeItemAssignment = PublishedRoomItemAssignment.find(auditInfo.auditable_id) # get the associated program item assignment
    programmeItem = programmeItemAssignment.published_programme_item # from that we can get the program item
    if auditInfo.changes["published_time_slot_id"] # if it is a change to the time slote then we report on that
      # the time slot has changed if we have an array of changed time information and that array contains more than one value      
      movedTime = auditInfo.changes["published_time_slot_id"].kind_of?(Array) && auditInfo.changes["published_time_slot_id"].size > 1
      
      if movedTime # Item X has been rescheduled from time A to time B
        oldtime = PublishedTimeSlot.find(auditInfo.changes["published_time_slot_id"][0]) if movedTime == true
        newtime = PublishedTimeSlot.find(auditInfo.changes["published_time_slot_id"][1])
      else # 
        newtime = PublishedTimeSlot.find(auditInfo.changes["published_time_slot_id"])
      end
      
      if movedTime && newtime.start != oldtime.start # then we have move time slot
        # Item X has been rescheduled from time A to time B
        resultantChanges = addPinkSheetEntryWithKey(resultantChanges, programmeItem, :update, :timeMove, oldtime.start, newtime.start)
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
                resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :detailUpdate, a.changes)
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
      if auditInfo.changes['published_room_id']
        if auditInfo.changes['published_room_id'].kind_of?(Array)
          fromRoom = PublishedRoom.find(auditInfo.changes["published_room_id"][0])
          room = PublishedRoom.find(auditInfo.changes["published_room_id"][1])
        else
          room = PublishedRoom.find(auditInfo.changes["published_room_id"])
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
