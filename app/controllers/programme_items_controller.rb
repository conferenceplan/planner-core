class ProgrammeItemsController < PlannerController
  include ProgramPlannerHelper

  #
  # Get the all the program items for a given person
  #
  def index
    if params[:person_id] # then we only get the items for a given person
      person = Person.find(params[:person_id])
      @programmeItems = person.programmeItems
    else
      @programmeItems = ProgrammeItem.find :all # Getting all the program items is probably not a good idea!!!!!
    end
  end

  #
  # Drop the given person from all their program items
  #
  def drop
    if params[:person_id]
      # Remove the person from the programme
      @person = Person.find(params[:person_id])

      @person.programmeItemAssignments.each do |assign|
        progitem = assign.programmeItem
        assign.destroy
        
        progitem.updated_at_will_change! # NOTE: this will force the update date of the programme item to be changed
        progitem.save
      end

    end

    render status: :ok, text: {}.to_json
  end
  
  #
  # Return a program item given an id
  #  
  def show
    @programmeItem = ProgrammeItem.find(params[:id])
    
    @invisibleAssociations = ProgrammeItemAssignment.find :all, :conditions => ['programme_item_id = ? AND role_id =?',@programmeItem,PersonItemRole['Invisible']], :include => {:person => :pseudonym}
    @moderatorAssociations = ProgrammeItemAssignment.find :all, :conditions => ['programme_item_id = ? AND role_id = ?', @programmeItem, PersonItemRole['Moderator']], :include => {:person => :pseudonym}
    @participantAssociations = ProgrammeItemAssignment.find :all, :conditions => ['programme_item_id = ? AND role_id = ?', @programmeItem, PersonItemRole['Participant']] , :include => {:person => :pseudonym}
    @reserveAssociations = ProgrammeItemAssignment.find :all, :conditions => ['programme_item_id = ? AND role_id = ?', @programmeItem, PersonItemRole['Reserved']] , :include => {:person => :pseudonym}
  end

  #
  # Create a new program item
  #  
  def create
    plain = params[:plain]
    # NOTE - name of the programmeItem passed in from form
    @programmeItem = ProgrammeItem.new(params[:programme_item])
    @programmeItem.lock_version = 0
    startTime = params[:start_time].to_datetime
    startDay = (startTime - Time.zone.parse(SITE_CONFIG[:conference][:start_date].to_s).to_datetime).to_i # NOT SET
    roomId = params[:room_id]

    begin
      ProgrammeItem.transaction do
        if @programmeItem.save
          if (startDay.to_i > -1) && startTime && (roomId.to_i > 0)
            room = Room.find(roomId)
            addItemToRoomAndTime(@programmeItem, room, startDay, startTime)
          end
        end
      end
    rescue Exception
      raise
    end
  end

  #
  # Update a program item based on the inputs
  #  
  def update
    @programmeItem = ProgrammeItem.find(params[:id])
    startTime = params[:start_time].to_datetime
    startDay = (startTime - Time.zone.parse(SITE_CONFIG[:conference][:start_date].to_s).to_datetime).to_i # NOT SET
    roomId = params[:room_id]
    
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
        end
      end
    rescue Exception
      raise
    end
  end
  
  #
  # Destroy the given program item
  #
  def destroy
    programmeItem = ProgrammeItem.find(params[:id])

    if programmeItem.time_slot
      TimeSlot.delete(programmeItem.time_slot.id)
    end
    if programmeItem.room_item_assignment
      RoomItemAssignment.delete(programmeItem.room_item_assignment.id)
    end
    
    programmeItem.destroy

    render status: :ok, text: {}.to_json
  end

  #
  # Get list of program items...
  #  
  def getList
    rows = params[:rows] ? params[:rows] : 15
    @page = params[:page] ? params[:page].to_i : 1
    idx = params[:sidx]
    order = params[:sord]
    context = params[:context]
    tags = params[:tags]
    nameSearch = params[:namesearch]
    filters = params[:filters]
    extraClause = params[:extraClause]

    @currentId = params[:current_selection]
    page_to = params[:page_to]
    
    ignoreScheduled = params[:igs] # TODO
    ignorePending = params[:igp]

    @count = ProgramItemsService.countItems filters, extraClause, nameSearch, context, tags, ignoreScheduled

    if page_to && !page_to.empty?
      gotoNum = ProgramItemsService.countItems filters, extraClause, nameSearch, context, tags, ignoreScheduled, page_to
      if gotoNum
        @page = (gotoNum / rows.to_i).floor
        @page += 1 if gotoNum % rows.to_i > 0
      end
    end
    # logger.debug "******** " + @count.to_s
    if rows.to_i > 0
      @nbr_pages = (@count / rows.to_i).floor
      @nbr_pages += 1 if @count % rows.to_i > 0
    else
      @nbr_pages = 1
    end
    
    @items = ProgramItemsService.findItems rows, @page, idx, order, filters, extraClause, nameSearch, context, tags, ignoreScheduled
  end

  #
  # Update the participants associated with this programme item
  #  
  def updateParticipants
    programmeItem = ProgrammeItem.find(params[:id])

    # 1. Clear out the current set of participants    
    programmeItem.people.clear # remove it from the person.
    programmeItem.updated_at_will_change! # NOTE: this will force the update date of the programme item to be changed
    programmeItem.save

    # 2. Create the new sets
    addParticipant(programmeItem.id, params['moderators'],PersonItemRole['Moderator'])
    addParticipant(programmeItem.id, params['participants'],PersonItemRole['Participant'])
    addParticipant(programmeItem.id, params['reserves'],PersonItemRole['Reserved'])
    addParticipant(programmeItem.id, params['invisibles'],PersonItemRole['Invisible'])
    
    @programmeItem = ProgrammeItem.find(params[:id])
    @invisibleAssociations = ProgrammeItemAssignment.find :all, :conditions => ['programme_item_id = ? AND role_id =?',@programmeItem,PersonItemRole['Invisible']], :include => {:person => :pseudonym}
    @moderatorAssociations = ProgrammeItemAssignment.find :all, :conditions => ['programme_item_id = ? AND role_id = ?', @programmeItem, PersonItemRole['Moderator']], :include => {:person => :pseudonym}
    @participantAssociations = ProgrammeItemAssignment.find :all, :conditions => ['programme_item_id = ? AND role_id = ?', @programmeItem, PersonItemRole['Participant']] , :include => {:person => :pseudonym}
    @reserveAssociations = ProgrammeItemAssignment.find :all, :conditions => ['programme_item_id = ? AND role_id = ?', @programmeItem, PersonItemRole['Reserved']] , :include => {:person => :pseudonym}
  end
  
  ###### Redundant ?????
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
                  ['format_id','pub_reference_number'],
                  ['format_id','pub_reference_number'])

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
    if (rows.to_i == 0)
      rows = '10'
    end
    @nbr_pages = (@count / rows.to_i).floor
    @nbr_pages += 1 if @count % rows.to_i > 0
    
    offset = (@page.to_i - 1) * rows.to_i
    if (idx != nil && idx != "")
       args.merge!(:offset => offset, :limit => rows, :order => idx + " " + order)
    else
       args.merge!(:offset => offset, :limit => rows, :order => "time_slots.start asc")
    end
      

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

  # ---------------------------------
  # TODO - these methods to be replaced by a service  
  def assign_reference_numbers
  end
  
  def do_assign_reference_numbers
      @programmeItems = ProgrammeItem.all(:include => [:time_slot, :room_item_assignment, {:people => :pseudonym}, {:room => [:venue]} ],
                                                 :order => 'time_slots.start ASC, venues.name DESC, rooms.name ASC',
                                                 :conditions => 'programme_items.print = true')
      itemNumber = 5
      @programmeItems.each do |item|
        if (item.room_item_assignment != nil)
          item.pub_reference_number = itemNumber
          item.save       
          itemNumber = itemNumber+5
        end
      end
      
  end
  
private
  
  #
  #
  #
  def addParticipant(itemid, participants, role)
    if participants
      participants.each do |personHash|
        p = Person.find(personHash['id'])
        assignment = ProgrammeItemAssignment.create(:programme_item_id => itemid, :person => p, :role => role)
        assignment.save
      end
    end
  end
  
 
end
