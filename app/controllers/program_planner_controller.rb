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
    args.merge!(:joins => 'LEFT JOIN time_slots ON time_slots.id = time_slot_id LEFT JOIN rooms ON rooms.id = room_id LEFT JOIN venues ON venues.id = rooms.venue_id')
    args.merge!(:order => 'rooms.name asc, time_slots.start asc')
    args.merge!(:include => [:time_slot, :programme_item, :room]) # eager loads the associated objects to reduce number of queries
    
    @roomAssignments = RoomItemAssignment.find :all, args
    @roomListing = Room.all(:order => 'rooms.name ASC')
    @currentDate = Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + day.to_i.day
    
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
    times = time.split(':') # hours and minutes
    itemStartTime = Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + 
    @day.to_i.days + times[0].to_i.hours + times[1].to_i.minutes
    itemEndTime = itemStartTime + @item.duration.minute
    oldRoom = @room
    
    RoomItemAssignment.transaction do # ensure that all the changes are done within the one transaction
      # 1. Figure out where the item is going to be placed
      newTimeSlot = TimeSlot.new(:start => itemStartTime, :end => itemEndTime)
      newTimeSlot.save
      
      if @item.room_item_assignment != nil 
        candidate = @item.room_item_assignment
        candidate.programme_item = nil
        candidate.save
        oldRoom = candidate.room
      end
      
      # 2. Split the free time into two (before and after the item)
      if @freetime.start < newTimeSlot.start
        newFreetime = TimeSlot.new(:start => @freetime.start, :end => newTimeSlot.start)
        newFreetime.save
        freeAssignment = RoomItemAssignment.new(:room => @room, :time_slot => newFreetime, :day => @day)
        freeAssignment.save
      end
      @freetime.start = newTimeSlot.end
      @freetime.save
      
      # Create the new assignment
      assignment = RoomItemAssignment.new(:room => @room, :time_slot => newTimeSlot, :day => @day, :programme_item => @item)
      assignment.save
    end
    defragmentFreeTimes(@room, @day)
    if (oldRoom != @room)
      defragmentFreeTimes(oldRoom, @day)
    end
    
    render :layout => 'content'
  end
  
  #
  # Unschedule an item
  #
  def removeItem
    @item = ProgrammeItem.find(params[:itemid])
    @room = Room.find(params[:roomid])
    
    #
    # 1. Unassociate a room with the program item i.e. remove the program item from the association
    candidate = @item.room_item_assignment
    day = candidate.day
    room = candidate.room
    candidate.programme_item = nil
    candidate.save
    
    # 2. Take the time slot and merge back into free time
    defragmentFreeTimes(room, day)
    
    render :layout => 'content'
  end
  
  def getConflicts
    @day = params[:day]
    query = CONFLICT_QUERY_PT1
    if (@day)
      query += 'AND roomA.day = ' + @day.to_s+ ' AND roomB.day = ' + @day.to_s
    end
    query += CONFLICT_QUERY_PT2
    @conflicts = ActiveRecord::Base.connection.select_rows(query)
    #    Room.find_by_sql(CONFLICT_QUERY)
    
    respond_to do |format|
      format.html { 
        if @day
          render :layout => 'plain'
        end
      }
    end
  end
  
  protected
  
  # Defragment the free times for this room on the given day !!
  # 1. get the free times for the room - 
  # i.e. the room item assigments that do not have a programme item associated with them, order by start time
  def defragmentFreeTimes(room, day)
    RoomItemAssignment.transaction do # ensure that all the changes are done within the one transaction
      emptyTimes = RoomItemAssignment.all(:conditions => ["room_id = ? AND day = ? AND programme_item_id is null AND time_slots.start = time_slots.end", room.id, day],
                          :joins => "LEFT JOIN time_slots ON time_slots.id = time_slot_id ",
                          :order => "time_slots.start asc" )
      if emptyTimes.size > 0
        for idx in 0 ... emptyTimes.size
          ts = TimeSlot.find(emptyTimes[idx].time_slot.id)
          f = RoomItemAssignment.find(emptyTimes[idx].id)
          ts.destroy
          f.destroy
        end
      end
    end
    
    RoomItemAssignment.transaction do # ensure that all the changes are done within the one transaction
      fts = RoomItemAssignment.all(:conditions => ["room_id = ? AND day = ? AND programme_item_id is null", room.id, day],
                          :joins => "LEFT JOIN time_slots ON time_slots.id = time_slot_id ",
                          :order => "time_slots.start asc" )
      if fts.size > 1
        for idx in 1 ... fts.size
          if fts[idx].time_slot.start == fts[idx-1].time_slot.end
            fts[idx].time_slot.start = fts[idx-1].time_slot.start # we need this so that the math works
            # But since the find was with a join we need to do new finds to make actual database updates
            ts = TimeSlot.find(fts[idx].time_slot.id)
            ts.start = fts[idx-1].time_slot.start
            ts.save
            tso = TimeSlot.find(fts[idx-1].time_slot.id)
            tso.destroy
            f = RoomItemAssignment.find(fts[idx-1].id)
            f.destroy
          end
        end
      end
    end
  end
  
CONFLICT_QUERY_PT1 = <<"EOS"
  select 
  R.id id, R.name name,
  P.id person_id, P.first_name person_first_name, P.last_name, 
  S.id item_id, S.title item_name, Conflicts.startA item_start,
  RB.id conflict_room_id, RB.name conflict_room_name,
  SB.id conflict_item_id, SB.title conflict_item_title,
  Conflicts.startB conflict_start
  from people P, rooms R, programme_items S,
  rooms RB, programme_items SB, 
   (select progA.person_id pidA, progB.person_id pidB, 
   roomA.room_id roomA, progA.programme_item_id progA, 
   progA.role_id roleA, progB.role_id roleB, tsA.start startA, tsA.end endA,
   roomB.room_id roomB, progB.programme_item_id progB, tsB.start startB, tsA.end endB
   from programme_item_assignments progA, room_item_assignments roomA, time_slots tsA,
   programme_item_assignments progB, room_item_assignments roomB, time_slots tsB
   where
   roomA.programme_item_id = progA.programme_item_id AND roomA.time_slot_id = tsA.id AND
   roomB.programme_item_id = progB.programme_item_id AND roomB.time_slot_id = tsB.id AND
   (tsA.start < tsB.start OR (tsA.start = tsB.start AND progA.programme_item_id < progB.programme_item_id))
  AND tsA.end > tsB.start
  AND progA.programme_item_id <> progB.programme_item_id
  AND progA.person_id = progB.person_id
  AND progA.role_id = progB.role_id
EOS
  
CONFLICT_QUERY_PT2 = <<"EOS"
  ) as Conflicts
  where
  R.id = Conflicts.roomA AND
  P.id = Conflicts.pidA AND
  S.id = Conflicts.progA AND
  RB.id = Conflicts.roomB AND
  SB.id = Conflicts.progB
  order by P.id
EOS
  
end
