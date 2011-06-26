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
  #
  def updates
    # To get the updates:
    # Get a list of all publications that have changed since the last publication date
    lastPubDate = PublicationDate.last
    
    @listOfAdds = []
    
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
        end
      else  
        if audit.auditable_type == "PublishedProgrammeItemAssignment" # person added or removed
          # Get the programme item assignments that have changed - this is the set of people
          programmeItem = PublishedProgrammeItem.find(audit.changes["published_programme_item_id"])
          role = PersonItemRole[audit.changes["role_id"]]
          person = Person.find(audit.changes["person_id"])
          @listOfAdds << person.GetFullPublicationName + " " + audit.action + " " + programmeItem.title + " as " + role.name
        elsif audit.auditable_type == "PublishedRoomItemAssignment" # item added, or moved
          # Get all the room item assignments that have changed - this is the set of rooms and times
          programmeItemAssignment = PublishedRoomItemAssignment.find(audit.auditable_id)
          programmeItem = programmeItemAssignment.published_programme_item
          oldtime = PublishedTimeSlot.find(audit.changes["published_time_slot_id"][audit.changes["published_time_slot_id"].size-2])
          newtime = PublishedTimeSlot.find(audit.changes["published_time_slot_id"][audit.changes["published_time_slot_id"].size-1])
          @listOfAdds <<  " " + programmeItem.title + " " + audit.action + " " + oldtime.start.strftime('%A %H:%M') + " to " + newtime.start.strftime('%A %H:%M')
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
