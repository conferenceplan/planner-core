class ProgrammeItemsController < PlannerController
  include ProgramPlannerHelper
  #
  # Get the all the program items for a given person
  #
  def index
    if params[:person_id] # then we only get the items for a given person
      @person = Person.find(params[:person_id])
      @assignments = @person.programmeItemAssignments.includes({:programmeItem => [:time_slot, :people]}).order('time_slots.start asc').collect{|a| (a.programmeItem != nil) ? a : nil}.compact
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
        
        progitem.id_will_change! # NOTE: this will force the update date of the programme item to be changed
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
    
    # Order these by last name
    @invisibleAssociations = ProgrammeItemAssignment.find :all, :conditions => ['programme_item_id = ? AND role_id =?',@programmeItem,PersonItemRole['Invisible']], :include => {:person => :pseudonym}, :order => "people.last_name"
    @moderatorAssociations = ProgrammeItemAssignment.find :all, :conditions => ['programme_item_id = ? AND role_id = ?', @programmeItem, PersonItemRole['Moderator']], :include => {:person => :pseudonym}, :order => "people.last_name"
    @participantAssociations = ProgrammeItemAssignment.find :all, :conditions => ['programme_item_id = ? AND role_id = ?', @programmeItem, PersonItemRole['Participant']] , :include => {:person => :pseudonym}, :order => "people.last_name"
    @reserveAssociations = ProgrammeItemAssignment.find :all, :conditions => ['programme_item_id = ? AND role_id = ?', @programmeItem, PersonItemRole['Reserved']] , :include => {:person => :pseudonym}, :order => "people.last_name"
  end

  #
  # Create a new program item
  #  
  def create
    plain = params[:plain]
    # NOTE - name of the programmeItem passed in from form
    startTime = (params[:start_time] && params[:start_time].to_datetime) ? (params[:start_time].to_datetime + zone_delta(params[:start_time].to_datetime)) : nil
    startDay = -1
    startDay = (startTime - Time.zone.parse(SiteConfig.first.start_date.to_s).to_datetime).to_i if startTime
    roomId = params[:room_id]
    parent_id = params[:parent_id]

    begin
      ProgrammeItem.transaction do
        @programmeItem = ProgrammeItem.new(params[:programme_item])
        @programmeItem.lock_version = 0
        if @programmeItem.save
          if (startDay.to_i > -1) && startTime && (roomId.to_i > 0)
            room = Room.find(roomId)
            addItemToRoomAndTime(@programmeItem, room, startDay, startTime)
          end
        end

        if parent_id
          @programmeItem.parent_id = parent_id
          @programmeItem.save!

          if @programmeItem.parent
            @programmeItem.parent.touch
            @programmeItem.parent.save
          end
        end
      end
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end

  #
  # Update a program item based on the inputs
  #  
  def update
    startTime = (params[:start_time] && params[:start_time].to_datetime) ? (params[:start_time].to_datetime + zone_delta(params[:start_time].to_datetime)) : nil
    startDay = -1
    startDay = (startTime - Time.zone.parse(SiteConfig.first.start_date.to_s).to_datetime).to_i if startTime
    roomId = params[:room_id]
    parent_id = params[:parent_id]
    
    begin
      ProgrammeItem.transaction do
        @programmeItem = ProgrammeItem.find(params[:id])
        if @programmeItem.update_attributes(params[:programme_item])
          
          if (startDay.to_i > -1) && startTime && (roomId.to_i > 0)
            room = Room.find(roomId)
            addItemToRoomAndTime(@programmeItem, room, startDay, startTime)
          else
            if (@programmeItem.room_item_assignment)
               @programmeItem.room_item_assignment.destroy
            end
          end
          
          ts = @programmeItem.time_slot
          if (ts)
            ts.end = ts.start + @programmeItem.duration.minutes
            ts.save
          end
        end
        
        if parent_id
          @programmeItem.parent_id = parent_id
          @programmeItem.save!

          if @programmeItem.parent
            @programmeItem.parent.touch
            @programmeItem.parent.save
          end
        end
      end
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end
  
  #
  # Destroy the given program item
  #
  def destroy
    programmeItem = ProgrammeItem.find(params[:id])

    begin
      ProgrammeItem.transaction do
        programmeItem.destroy
    
        render status: :ok, text: {}.to_json
      end
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end
  
  #
  #
  #
  def list
    limit = params[:limit] ? params[:limit].to_i : nil
    offset = params[:offset] ? params[:offset].to_i : nil
    search = params[:search] ? params[:search] : nil

    sort_by = params[:sort] ? params[:sort] : 'title'
    sort_order = params[:order] ? params[:order] : 'asc'

    if search
      @total = ProgrammeItem.where(["title like ?", '%' + search + '%']).count
      @items = ProgrammeItem.where(["title like ?", '%' + search + '%']).offset(offset).limit(limit).order(sort_by + ' ' + sort_order)
    else
      @total = ProgrammeItem.count
      @items = ProgrammeItem.offset(offset).limit(limit).order(sort_by + ' ' + sort_order)
    end
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
    
    ignoreScheduled = params[:igs] == 'true' # TODO
    ignorePending = params[:igp] == 'true'

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

    begin
      ProgrammeItem.transaction do
        # 1. Clear out the current set of participants    
        programmeItem.people.clear # remove it from the person.
        programmeItem.id_will_change! # NOTE: this will force the update date of the programme item to be changed
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
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end
  
  # ---------------------------------
  def assign_reference_numbers
    ProgrammeItem.transaction do
      ProgramItemsService.assign_reference_numbers
    end
  end
  
private

  def zone_delta(_time)
    start_offset = Time.zone.parse(SiteConfig.first.start_date.to_s).to_datetime.in_time_zone.utc_offset
    item_offset = _time.in_time_zone.utc_offset
    ((start_offset - item_offset)/60).minutes
  end
  
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
