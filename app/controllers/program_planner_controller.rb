class ProgramPlannerController < PlannerController
  def index
  end
  
  #
  # Get the rooms and times for a given day
  # order by room and time
  #
  def list
    # Day
    day = params[:day]
    clause = addClause(nil, 'day = ?', day)

    # We need to know which rooms we are going for...
    args = { :conditions => clause }
    args.merge!(:joins => 'LEFT JOIN time_slots ON time_slots.id = time_slot_id LEFT JOIN rooms ON rooms.id = room_id')
    args.merge!(:order => 'rooms.id, time_slots.start')

    @roomAssignments = RoomItemAssignment.find :all, args
    
    @roomListing = Room.all(:order => 'rooms.id')

    respond_to do |format|
      format.html { render :layout => 'content' } # list.html.erb
      format.xml
    end
  end

  def edit
    @day = params[:day]
    @time = params[:time]
    @item_id = params[:itemid]
    @room_id = params[:roomid]
    @freetime_id = params[:timeid]
    
    
    render :layout => 'content'
  end
  
  #
  # Add an item to a room
  #
  def addItem
    day = params[:day]
    time = params[:time]
    item_id = params[:itemid]
    room_id = params[:roomid]
    freetime_id = params[:timeid]
    
    # 1. Split the freetime so that a new time slot is created for the item
    # 2. Create an association between the program item, time slot, and room
    #
    # NOTE: if this is a move i.e. already assigned then add the previous timeslot back into free time
    # need a mechanism to defragment the free time...
    
    render :layout => 'content'
  end
  
  #
  # Unschedule an item
  #
  def removeItem
    item_id = params[:itemid]
    room_id = params[:roomid]

    #
    # 1. Unassociate a room with the program item i.e. remove the program item from the association
    # 2. Take the time slot and merge back into free time
    #
    render :layout => 'content'
  end
  
end
