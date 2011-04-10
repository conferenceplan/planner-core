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
    args.merge!(:order => 'rooms.id, time_slots.start asc')

    @roomAssignments = RoomItemAssignment.find :all, args
    
    @roomListing = Room.all(:order => 'rooms.id')

    respond_to do |format|
      format.html { render :layout => 'content' } # list.html.erb
      format.xml
    end
  end

  def edit
    @day = params[:day]
    @time = params[:time] # In hh:mm format - this is the start time...
    @item = ProgrammeItem.find(params[:itemid])
    @room = Room.find(params[:id])
    @freetime = TimeSlot.find(params[:timeid])
    
    render :layout => 'content'
  end
  
  #
  # Add an item to a room
  #
  def addItem
    @item = ProgrammeItem.find(params[:itemid])
    @room = Room.find(params[:roomid])
    @freetime = TimeSlot.find(params[:timeid]) # The time slot from which to take the period that the item is using
    @day = params[:day]
    time = params[:time] # The start time in hours and minutes for the programme item
    times = time.split(':')
    itemHour = times[0]
    itemMinute = times[1]
    # works cause conf start is at 0 hours... TODO - change to make more generic
    itemStartTime = Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + 
      @day.to_i.days + itemHour.to_i.hours + itemMinute.to_i.minutes
    itemEndTime = itemStartTime + @item.duration.minute
    candidate = nil

    if @item.room_item_assignments != nil 
      candidate = @item.room_item_assignment
    end

    # 1. Split the freetime so that a new time slot is created for the item
    # New free time gets a start time equal to the end time of the item 
    #  and an end time equal to the end time of the old free time.
    newFreetime = TimeSlot.new(:start => @freetime.start, :end => itemStartTime)
    # Free time gets a new end time equal to the start time of the item.
    @freetime.start = itemEndTime
    itemTimeSlot = TimeSlot.new(:start => itemStartTime, :end => itemEndTime)

    # now save everything and create the room assignment
    newFreetime.save
    freeAssignment = RoomItemAssignment.new(:room => @room, :time_slot => newFreetime, :day => @day)
    freeAssignment.save

    @freetime.save
    itemTimeSlot.save

    # 2. Create an association between the program item, time slot, and room
    assignment = RoomItemAssignment.new(:room => @room, :time_slot => itemTimeSlot, :day => @day, :programme_item => @item)
    assignment.save
    
    if candidate != nil
      candidate.programme_item = nil
      candidate.save
    end

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
