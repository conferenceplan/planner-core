class ProgrammeItemsController < PlannerController
  include ProgramPlannerHelper
  
  def index
    if params[:person_id] # then we only get the items for a given person
      @person = Person.find(params[:person_id])
      @programmeItems = @person.programmeItems
      render :template => 'people/items', :layout => 'content'
    else
      @programmeItems = ProgrammeItem.find :all
    end
  end
  def show
    plain = params[:plain]
    @programmeItem = ProgrammeItem.find(params[:id])
    @editable = params[:edit] ? params[:edit] == "true" : true
    
    @moderatorAssociations = ProgrammeItemAssignment.find :all, :conditions => ['programme_item_id = ? AND role_id = ?', @programmeItem, PersonItemRole['Moderator']] 
    @participantAssociations = ProgrammeItemAssignment.find :all, :conditions => ['programme_item_id = ? AND role_id = ?', @programmeItem, PersonItemRole['Participant']] 
    @reserveAssociations = ProgrammeItemAssignment.find :all, :conditions => ['programme_item_id = ? AND role_id = ?', @programmeItem, PersonItemRole['Reserved']] 

    if plain
      render :layout => 'content'
    else  
      render
    end
  end
  def create
    plain = params[:plain]
    # NOTE - name of the programmeItem passed in from form
    @programmeItem = ProgrammeItem.new(params[:programme_item])
    @programmeItem.lock_version = 0
    startDay = params[:start_day]
    startTime = params[:start_time]
    roomId = params[:room]
    saved = false

    begin
      ProgrammeItem.transaction do
        if @programmeItem.save
          if (startDay.to_i > -1) && startTime && (roomId.to_i > 0)
            room = Room.find(roomId)
            addItemToRoomAndTime(@programmeItem, room, startDay, startTime)
          end
          saved = true
        else
          saved = false
        end
      end
    rescue Exception
      saved = false
      raise
    end

    if saved
      if plain
        redirect_to :action => 'show', :id => @programmeItem, :plain => plain
      else  
        redirect_to :action => 'show', :id => @programmeItem
      end
    else
      render :action => 'new'
    end 
  end

  def new
    @programmeItem = ProgrammeItem.new
    @programmeItem.duration = 60
    @programmeItem.minimum_people = 3
    @programmeItem.maximum_people = 5
    @programmeItem.print = true
  end
  
  def edit
    @programmeItem = ProgrammeItem.find(params[:id])
    render :layout => 'content'
  end

  def update
    saved = false
    @programmeItem = ProgrammeItem.find(params[:id])
    startDay = params[:start_day]
    startTime = params[:start_time]
    roomId = params[:room]
    
    begin
      ProgrammeItem.transaction do
        
        if @programmeItem.update_attributes(params[:programme_item])
          if (startDay.to_i > -1) && startTime && (roomId.to_i > 0)
            room = Room.find(roomId)
            addItemToRoomAndTime(@programmeItem, room, startDay, startTime)
          else
            if (@programmeItem.room_item_assignment)
               @programmeItem.room_item_assignment.delete
            end
          end
          
          ts = @programmeItem.time_slot
          if (ts)
            ts.end = ts.start + @programmeItem.duration.minutes
            ts.save
          end
          saved = true
        else
          saved = false
        end
      end
    rescue Exception
      saved = false
      raise
    end

    if saved
        redirect_to :action => 'show', :id => @programmeItem, :plain => true
    else
      render :action => 'edit', :layout => 'content'
    end 
  end
  
  def destroy
    @programmeItem = ProgrammeItem.find(params[:id])

    if @programmeItem.time_slot
      TimeSlot.delete(@programmeItem.time_slot.id)
    end
    if @programmeItem.room_item_assignment
      RoomItemAssignment.delete(@programmeItem.room_item_assignment.id)
    end
    
    @programmeItem.destroy
    redirect_to :action => 'index'
  end
  #
  
  def list
    rows = params[:rows]
    @page = params[:page]
    idx = params[:sidx]
    order = params[:sord]
    context = params[:context]
    nameSearch = params[:namesearch]
    ignoreScheduled = params[:igs]
    ignorePending = params[:igp]

    clause = createWhereClause(params[:filters], 
                  ['format_id'],
                  ['format_id'])

    # add the name search of the title
    if nameSearch && ! nameSearch.empty?
      clause = addClause(clause,'title like ?','%' + nameSearch + '%')
    end
    if ignoreScheduled
      clause = addClause( clause, 'room_item_assignments.programme_item_id is null', nil )
    end
    if ignorePending
      clause = addClause( clause, 'pending_publication_items.programme_item_id is null', nil )
      clause = addClause( clause, 'programme_items.print = true', nil )
    end

    args = { :conditions => clause }
    
#    LEFT JOIN time_slots on time_slots.id = room_item_assignments.time_slot_id
    args.merge!( :joins => 'LEFT JOIN room_item_assignments ON room_item_assignments.programme_item_id = programme_items.id ' +
                           'LEFT JOIN time_slots on time_slots.id = room_item_assignments.time_slot_id ' +
                           'LEFT JOIN pending_publication_items on pending_publication_items.programme_item_id = programme_items.id ' )

    # First we need to know how many records there are in the database
    # Then we get the actual data we want from the DB
#    args.merge!(:include => :format)
    
    tagquery = ""
    if context
      if context.class == HashWithIndifferentAccess
        context.each do |key, ctx|
          tagquery += ".tagged_with('" + params[:tags][key].gsub(/'/, "\\\\'").gsub(/\(/, "\\\\(").gsub(/\)/, "\\\\)") + "', :on => '" + ctx + "', :any => true)"
        end
      else
        tagquery += ".tagged_with('" + params[:tags].gsub(/'/, "\\\\'").gsub(/\(/, "\\\\(").gsub(/\)/, "\\\\)") + "', :on => '" + context + "', :op => true)"
      end
    end
    
    # First we need to know how many records there are in the database
    # Then we get the actual data we want from the DB
    if tagquery.empty?
      @count = ProgrammeItem.count args
    else
      @count = eval "ProgrammeItem#{tagquery}.count :all, " + args.inspect
    end

    @nbr_pages = (@count / rows.to_i).floor
    @nbr_pages += 1 if @count % rows.to_i > 0
    
    offset = (@page.to_i - 1) * rows.to_i
    args.merge!(:offset => offset, :limit => rows, :order => "time_slots.start asc, " + idx + " " + order)
    if tagquery.empty?
      @programmeItems = ProgrammeItem.find :all, args
    else
      @programmeItems = eval "ProgrammeItem#{tagquery}.find :all, " + args.inspect
    end
    
    # We return the list of ProgrammeItems as an XML structure which the 'table' can use.
    respond_to do |format|
      format.html { render :layout => 'plain' } # list.html.erb
      format.xml
    end
  end
  
  #
  # Update the participants associated with this programme item
  #  
  def updateParticipants
    @programmeItem = ProgrammeItem.find(params[:id])

    # 1. Clear out the current set of participants    
    @programmeItem.people.clear # remove it from the person.
    @programmeItem.updated_at_will_change! # NOTE: this will force the update date of the programme item to be changed
    @programmeItem.save
    
    # 2. Create the new set
    moderators = params['item-moderator-participants'] # this is a collection of the information about the participants to add (id and role)
    if moderators
      moderators.each do |candidate_id, candidate|
        p = Person.find(candidate[:person_id])
        # NOTE : had to put the programme item id in there explicitly because AR seemed not to work it out when using :programmeItem...
        # Using this mechanism so we can specify the role(s)
        assignment = ProgrammeItemAssignment.create(:programme_item_id => @programmeItem.id, :person => p, :role => PersonItemRole['Moderator'])
        assignment.save
      end
    end
    
    # 2. Create the new set
    candidates = params['item-participants'] # this is a collection of the information about the participants to add (id and role)
    if candidates
      candidates.each do |candidate_id, candidate|
        p = Person.find(candidate[:person_id])
        # NOTE : had to put the programme item id in there explicitly because AR seemed not to work it out when using :programmeItem...
        # Using this mechanism so we can specify the role(s)
        assignment = ProgrammeItemAssignment.create(:programme_item_id => @programmeItem.id, :person => p, :role => PersonItemRole['Participant'])
        assignment.save
      end
    end
    
    reserve = params['item-reserve-participants'] # this is a collection of the information about the participants to add (id and role)
    if reserve
      reserve.each do |candidate_id, candidate|
        p = Person.find(candidate[:person_id])
        assignment = ProgrammeItemAssignment.create(:programme_item_id => @programmeItem.id, :person => p, :role => PersonItemRole['Reserved'])
        assignment.save
      end
    end
  
    respond_to do |format|
      format.html { render :layout => 'content' } # updateParticipants.html.erb
      format.xml
    end
  end
  def showEquipment
    @programmeItem = ProgrammeItem.find(params[:id])
    
  end
 
end
