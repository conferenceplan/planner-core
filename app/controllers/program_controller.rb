class ProgramController < ApplicationController
  
  #
  # Get the full programme
  # If the day is specified then just return the items for that day
  # Can return formatted as an Atom feed or plain HTML
  #
  def index
    day = params[:day] # Day
    name = params[:name]
    stream = params[:stream]
    
    conditionStr = 'published_room_item_assignments.day = ? ' if day
    conditionStr += ' AND ' if day && name
    conditionStr += 'people.last_name like ? OR people.first_name like ? ' if name
    conditions = [conditionStr] if day || name
    conditions += [day] if day
    conditions += ['%'+name+'%', '%'+name+'%'] if name
    
    roomconditions = ['published_room_item_assignments.day = ?', day] if day
    
    @rooms = PublishedRoom.all(:select => 'distinct published_rooms.*, published_venues.name as v_name',
                               :order => 'v_name DESC, published_rooms.name ASC', 
                               :joins => [:published_venue, :published_room_item_assignments],
                               :conditions => roomconditions)
    
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
#      :joins => "LEFT OUTER JOIN `taggings` ON (`published_programme_items`.`id` = `taggings`.`taggable_id` AND `taggings`.`taggable_type` = 'PublishedProgrammeItem') LEFT OUTER JOIN tags ON (tags.id = taggings.tag_id) AND taggings.tagger_id IS NULL AND taggings.context = 'PrimaryArea'",

    respond_to do |format|
      format.html { render :layout => 'content' } # This should generate an HTML grid
      format.atom # for an Atom feed (for readers)
      format.js { render :json => @programmeItems.to_json(
        :except => [:created_at , :updated_at, :lock_version, :format_id, :id],
        :include => [:published_time_slot, :published_room]
        ) }
    end
  end
  
  def rooms
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.atom # for an Atom feed (for readers)
    end
  end
  
  def streams
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.atom # for an Atom feed (for readers)
    end
  end
  
  def participants
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.atom # for an Atom feed (for readers)
    end
  end
  
end
