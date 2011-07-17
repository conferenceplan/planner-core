class ProgramController < ApplicationController
  
  #
  # Get the full programme
  # If the day is specified then just return the items for that day
  # Can return formatted as an Atom feed or plain HTML
  #
  def index
    stream = params[:stream]
    layout = params[:layout]
    conditions = getConditions(params)
    
    @rooms = PublishedRoom.all(:select => 'distinct published_rooms.name',
                               :order => 'published_venues.name DESC, published_rooms.name ASC', 
                               :include => [:published_venue, {:published_room_item_assignments => {:published_programme_item => {:people => :pseudonym}}}],
                               :conditions => conditions)
    
    if stream
      @programmeItems = PublishedProgrammeItem.tagged_with( stream, :on => 'PrimaryArea', :op => true).all(
                                                 :include => [:publication, :published_time_slot, :published_room_item_assignment, {:people => [:pseudonym, :edited_bio]}, {:published_room => [:published_venue]} ],
                                                 :order => 'published_time_slots.start ASC, published_venues.name DESC, published_rooms.name ASC',
                                                 :conditions => conditions)
    else
      @programmeItems = PublishedProgrammeItem.all(:include => [:publication, :published_time_slot, :published_room_item_assignment, {:people => [:pseudonym, :edited_bio]}, {:published_room => [:published_venue]} ],
                                                 :order => 'published_time_slots.start ASC, published_venues.name DESC, published_rooms.name ASC',
                                                 :conditions => conditions)
    end
    
    ActiveRecord::Base.include_root_in_json = false # hack for now
     
    respond_to do |format|
      format.html { 
        if layout && layout == 'line'
          render :action => :list, :layout => 'content' 
        else  
          render :layout => 'content' 
        end
      } # This should generate an HTML grid
      format.atom # for an Atom feed (for readers)
      format.js { render_json @programmeItems.to_json(
        :except => [:created_at , :updated_at, :lock_version, :format_id],
        :methods => [:shortDate, :timeString, :bio, :pub_number],
        :include => {:published_time_slot => {}, :published_room => {:include => :published_venue}, :people => {:include => {:pseudonym => {}}}}
        ) }
#      format.js { render :json => @programmeItems.to_json(
#        :except => [:created_at , :updated_at, :lock_version, :format_id, :id],
#        :include => [:published_time_slot, :published_room]
#        ) }
    end
  end
  
  #
  # Return a list of rooms - use the same parameters as for the grid
  #
  def rooms
    conditions = getConditions(params)
    
    @rooms = PublishedRoom.all(:select => 'distinct published_rooms.name',
                               :order => 'published_venues.name DESC, published_rooms.name ASC', 
                               :include => [:published_venue, {:published_room_item_assignments => {:published_programme_item => {:people => :pseudonym}}}],
                               :conditions => conditions)
    
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.js { render_json @rooms.to_json(:except => [:created_at , :updated_at, :lock_version, :id, :published_venue_id],
                                                 :include => [:published_venue]
        ) }
    end
  end
  
  #
  # Return a list of the programme streams
  #
  def streams
    tags = PublishedProgrammeItem.tag_counts_on( 'PrimaryArea' )
    
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.js { render_json tags.to_json(
                                    :except => [:created_at , :updated_at, :lock_version, :id, :count]
        ) }
    end
  end
  
  def participants
    @participants = ActiveRecord::Base.connection.select_rows(PARTICIPANT_QUERY)
    
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.js { render_json  @participants.to_json(
        ) }
    end
  end
  
  #
  # What is coming up in the next x hours
  #
  def feed
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.atom # for an Atom feed (for readers)
    end
  end
  
  #
  # Report back on what has changed. This is used to generate the pink sheets.
  #
  # TODO - would be a good idea to find a mechanism to cache this so as to minimise queries
  #
  # Item time and room changes
  # New Items
  # Dropped Items
  # Participants Added
  # Participants Dropped
  #
  # Title and Description changes
  #
  # Person add
  # Person roleChange
  # Person remove
  #
  #
  def updates
    @resultantChanges = {}
    
    # To get the updates:
    # Get a list of all publications that have changed since the last publication date
    @lastPubDate = PublicationDate.last
    
    if !@lastPubDate
      return
    end
    
    audits = Audit.all(
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like ?)", @lastPubDate.timestamp, 'Published%'],
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
          @resultantChanges = addPinkSheetEntryWithKey(@resultantChanges, id , :removeItem , :title, title) # TODO - add other values from the audit table provide more info i.e. dropped from day & time
        elsif audit.auditable_type == "PublishedProgrammeItemAssignment" # person was removed...
          begin
            programmeItem = PublishedProgrammeItem.find(audit.changes["published_programme_item_id"]) # this will fail
            role = PersonItemRole[audit.changes["role_id"]]
            person = Person.find(audit.changes["person_id"])
            @resultantChanges = addPinkSheetEntry(@resultantChanges, programmeItem, :removePerson, person, role)
          rescue
            # do nowt, kuldge to get round assigment destroys where programme item does not exist
          end
        elsif audit.auditable_type == 'PublishedRoomItemAssignment'
          id = audit.changes['published_programme_item_id']
          room = PublishedRoom.find(audit.changes['published_room_id'])
          timeAudit = Audit.all(
            :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like ?) AND (audits.auditable_id = ?)", 
              @lastPubDate.timestamp, 'PublishedTimeSlot%', audit.changes['published_time_slot_id']]
          )
          @resultantChanges = addPinkSheetEntryWithKey(@resultantChanges, id, :removeItem, :info, room, timeAudit[0].changes['start'])
        end # we are ignoring the destroys of the room item assignment and the timeslot... TODO - collect for information on the prog item
      else  
        if audit.auditable_type == "PublishedProgrammeItemAssignment" # person added or removed
          @resultantChanges = getPeopleChange(audit, @resultantChanges)
        elsif audit.auditable_type == "PublishedRoomItemAssignment" # item added, or moved
            @resultantChanges = getItemChange(audit, @resultantChanges)
        end
      end
    end
    
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.atom # for an Atom feed (for readers)
    end
  end
  
  protected
  
  def getProgrammeItemChanges(id)
    audits = Audit.all(
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like ?) AND (audits.auditable_id = ?)", @lastPubDate.timestamp, 'PublishedProgrammeItem', id],
      :order => "audits.created_at asc"
    )
    
    return audits
  end
  
  def getPeopleChange(auditInfo, resultantChanges)
    # Get the programme item assignments that have changed - this is the set of people
    if auditInfo.changes["published_programme_item_id"] # Add person
      programmeItem = PublishedProgrammeItem.find(auditInfo.changes["published_programme_item_id"])
      role = PersonItemRole[auditInfo.changes["role_id"]]
      person = Person.find(auditInfo.changes["person_id"])
      resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :addPerson, person, role)
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
  
  #
  #
  
  #
  # Item add
  # Item move
  #
  # { programmeItem => [action, action, action] }
  # action == {'timeMove' => [from, to]}
  # action == {'roomMove' => to}
  # action == 'add'
  #
  def getItemChange(auditInfo, resultantChanges)
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
        else
          # TODO - if the item was update (Title etc) then it is not a new....
          # Look for the PublishedProgrammeItem and see if it is an update
          if (auditInfo.action == 'update')
            auditChange = getProgrammeItemChanges(programmeItem.id);
            if auditChange
              auditChange.each do |a|
                resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :updateDetails, a.changes)
              end
            end
          else  
            resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :new, newtime.start)
          end
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
  def addPinkSheetEntry(resultCollection, programmeItem, operation, *args)
    
    if resultCollection[operation]
      if resultCollection[operation][programmeItem]
        resultCollection[operation][programmeItem].concat args
      else
        resultCollection[operation][programmeItem] = args
      end
    else
      resultCollection[operation] = {programmeItem => args}
    end
    
    return resultCollection
  end
  
  def addPinkSheetEntryWithKey(resultCollection, programmeItem, operation, key, *args)
    
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

  def getConditions(params)
    day = params[:day] # Day
    name = params[:name]
    lastname = params[:lastname]
    
    conditionStr = "" if day || name || lastname
    conditionStr += '(published_room_item_assignments.day = ?) ' if day
    conditionStr += ' AND ' if day && (name || lastname)
    conditionStr += '(people.last_name like ? OR pseudonyms.last_name like ? OR people.first_name like ? OR pseudonyms.first_name like ? )' if name && !lastname
    conditionStr += '((people.last_name like ? OR pseudonyms.last_name like ?) AND (people.first_name like ? OR pseudonyms.first_name like ?))' if name && lastname
    conditionStr += '(people.last_name like ? OR pseudonyms.last_name like ?)' if lastname && !name
    conditions = [conditionStr] if day || name || lastname
    conditions += [day] if day 
    lastname = name if !lastname
    conditions += ['%'+lastname+'%', '%'+lastname+'%', '%'+name+'%', '%'+name+'%'] if name
    conditions += ['%'+lastname+'%', '%'+lastname+'%'] if lastname && !name
    
    return conditions
  end
  
PARTICIPANT_QUERY = <<"EOS"
  select distinct 
  case when pseudonyms.first_name is not null AND char_length(pseudonyms.first_name) > 0 then pseudonyms.first_name else people.first_name end as first_name,
  case when pseudonyms.last_name is not null AND char_length(pseudonyms.last_name) > 0 then pseudonyms.last_name else people.last_name end as last_name
  from people
  join published_programme_item_assignments on published_programme_item_assignments.person_id = people.id
  left join pseudonyms ON pseudonyms.person_id = people.id
  ORDER BY last_name;
EOS
  
end
