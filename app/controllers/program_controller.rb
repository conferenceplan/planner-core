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
                                                 :include => [:publication, :published_time_slot, :published_room_item_assignment, {:people => :pseudonym}, {:published_room => [:published_venue]} ],
                                                 :order => 'published_time_slots.start ASC, published_venues.name DESC, published_rooms.name ASC',
                                                 :conditions => conditions)
    else
      @programmeItems = PublishedProgrammeItem.all(:include => [:publication, :published_time_slot, :published_room_item_assignment, {:people => :pseudonym}, {:published_room => [:published_venue]} ],
                                                 :order => 'published_time_slots.start ASC, published_venues.name DESC, published_rooms.name ASC',
                                                 :conditions => conditions)
    end
    
    respond_to do |format|
      format.html { 
        if layout && layout == 'line'
          render :action => :list, :layout => 'content' 
        else  
          render :layout => 'content' 
        end
      } # This should generate an HTML grid
      format.atom # for an Atom feed (for readers)
      format.js { render :json => @programmeItems.to_json(
        :except => [:created_at , :updated_at, :lock_version, :format_id, :id],
        :include => [:published_time_slot, :published_room]
        ) }
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
      format.js { render :json => @rooms.to_json(:except => [:created_at , :updated_at, :lock_version, :id, :published_venue_id],
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
      format.js { render :json => tags.to_json(
                                    :except => [:created_at , :updated_at, :lock_version, :id, :count]
        ) }
    end
  end
  
  def participants
    @participants = ActiveRecord::Base.connection.select_rows(PARTICIPANT_QUERY)
    
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.js { render :json => @participants.to_json(
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
  # What has been changed since X
  # TODO - would be a good idea to find a mechanism to cache this so as to minimise queries
  #
  def updates
    # To get the updates:
    # Get a list of all publications that have changed since the last publication date
    lastPubDate = PublicationDate.last
    
    @listOfAdds = []
    
    # TODO - do items first then assignments, also if item has been removed we do not need the remove from it...
    audits = Audit.all(
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like ?)", lastPubDate.timestamp, 'Published%'],
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
          @listOfAdds <<  " " + title + " " + audit.action
          # need to know what the time was ....
        elsif audit.auditable_type == "PublishedProgrammeItemAssignment" # person was removed...
          # TODO - we do not want to go in here if the person removal was because of the programme item removal
          begin
            programmeItem = PublishedProgrammeItem.find(audit.changes["published_programme_item_id"]) # this will fail
            role = PersonItemRole[audit.changes["role_id"]]
            person = Person.find(audit.changes["person_id"])
            @listOfAdds << person.GetFullPublicationName + " " + audit.action + " " + programmeItem.title + " as " + role.name
          rescue
            # do nowt, kuldge to get round assigment destroys where programme item does not exist
          end
        end
      else  
        if audit.auditable_type == "PublishedProgrammeItemAssignment" # person added or removed
          # Get the programme item assignments that have changed - this is the set of people
          if audit.changes["published_programme_item_id"]
            programmeItem = PublishedProgrammeItem.find(audit.changes["published_programme_item_id"])
            role = PersonItemRole[audit.changes["role_id"]]
            person = Person.find(audit.changes["person_id"])
            @listOfAdds << person.GetFullPublicationName + " " + audit.action + " " + programmeItem.title + " as " + role.name
          else
            if audit.changes["role_id"].kind_of?(Array) # then we have a role change
              newrole = PersonItemRole[audit.changes["role_id"][1]]
              assignment = PublishedProgrammeItemAssignment.find(audit.auditable_id)
              programmeItem = assignment.published_programme_item
              person = assignment.person
              if newrole != PersonItemRole['Reserved']
                oldrole = PersonItemRole[audit.changes["role_id"][0]]
                @listOfAdds << person.GetFullPublicationName + " " + audit.action + " " + programmeItem.title + " as " + newrole.name
              else
                @listOfAdds << person.GetFullPublicationName + " removed from " + programmeItem.title
              end
            end
          end
        elsif audit.auditable_type == "PublishedRoomItemAssignment" # item added, or moved
          # Get all the room item assignments that have changed - this is the set of rooms and times
          # TODO - when there were no people originally then we get a "new" assignment with an oldtime == newtime... Why?
          programmeItemAssignment = PublishedRoomItemAssignment.find(audit.auditable_id)
          programmeItem = programmeItemAssignment.published_programme_item
          if audit.changes["published_time_slot_id"]
            movedTime = audit.changes["published_time_slot_id"].kind_of?(Array) && audit.changes["published_time_slot_id"].size > 1
            if audit.changes["published_time_slot_id"].kind_of?(Array)
              oldtime = PublishedTimeSlot.find(audit.changes["published_time_slot_id"][audit.changes["published_time_slot_id"].size-2]) if movedTime == true
              newtime = PublishedTimeSlot.find(audit.changes["published_time_slot_id"][audit.changes["published_time_slot_id"].size-1])
            else
              newtime = PublishedTimeSlot.find(audit.changes["published_time_slot_id"])
            end
            if movedTime && newtime.start != oldtime.start # then we have move time slot
              @listOfAdds <<  " " + programmeItem.title + " " + audit.action + " " + oldtime.start.strftime('%A %H:%M') + " to " + newtime.start.strftime('%A %H:%M')
            else
              @listOfAdds <<  " " + programmeItem.title + " " + audit.action + " to " + newtime.start.strftime('%A %H:%M')
            end
          else # check if we have move room/venue
#            audit.changes["published_room_id"]
            @listOfAdds <<  " " + programmeItem.title + " " + audit.action
          end
        end
      end
    end
    
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.atom # for an Atom feed (for readers)
    end
  end
  
  protected
  
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
