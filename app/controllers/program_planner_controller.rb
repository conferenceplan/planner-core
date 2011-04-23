class ProgramPlannerController < PlannerController
  def index
  end
  
  #
  # Get the rooms and times for a given day
  # order by room and time
  #
  def list
    # Day
    @day = params[:day]
    @roomListing = Room.all(:order => 'rooms.name ASC') #, :include => [:room_item_assignments]) # need to limit by day?
    
    @currentDate = Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + @day.to_i.day
    
    respond_to do |format|
      format.html { render :layout => 'content' } # list.html.erb
      format.xml
    end
  end
  
  def edit
    @day = params[:day]
    @item = ProgrammeItem.find(params[:itemid])
    @room = Room.find(params[:id])
    
    render :layout => 'content'
  end
  
  #
  # Add an item to a room
  #
  def addItem
    @item = ProgrammeItem.find(params[:itemid])
    @room = Room.find(params[:roomid])
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
        removeAssignment(@item.room_item_assignment)
      end
      
      # Create the new assignment
      assignment = RoomItemAssignment.new(:room => @room, :time_slot => newTimeSlot, :day => @day, :programme_item => @item)
      assignment.save
    end
    
    render :layout => 'content'
  end
  
  #
  # Unschedule an item
  #
  def removeItem
    @item = ProgrammeItem.find(params[:itemid])
    @room = Room.find(params[:roomid])

    removeAssignment(@item.room_item_assignment)
    
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

    query = ITEM_CONFLICT_QUERY_PT1
    if (@day)
      query += 'AND roomA.day = ' + @day.to_s+ ' AND roomB.day = ' + @day.to_s
    end
    query += ITEM_CONFLICT_QUERY_PT2
    @roomConflicts = ActiveRecord::Base.connection.select_rows(query)
    
    respond_to do |format|
      format.html { 
        if @day
          render :layout => 'plain'
        end
      }
    end
  end
  
  protected
  
  def removeAssignment(candidate)
    RoomItemAssignment.transaction do
      # 1. Unassociate a room with the program item i.e. remove the program item from the association
      candidate.time_slot.delete
      candidate.delete
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

ITEM_CONFLICT_QUERY_PT1 = <<"EOS"
select room.id, room.name name, 
S.id item_id, S.title item_name,
SB.id conflict_item_id, SB.title conflict_item_name,
Conflicts.startA item_start,
Conflicts.startB conflict_start
from
Rooms room, programme_items S, programme_items SB,
(select 
   roomA.room_id roomA, roomA.programme_item_id progA, tsA.start startA, tsA.end endA,
   roomB.room_id roomB, roomB.programme_item_id progB, tsB.start startB, tsA.end endB
from 
   room_item_assignments roomA, time_slots tsA,
   room_item_assignments roomB, time_slots tsB
where
    roomA.room_id = roomB.room_id
AND roomA.time_slot_id = tsA.id AND roomB.time_slot_id = tsB.id
AND (tsA.start < tsB.start OR (tsA.start = tsB.start AND roomA.programme_item_id < roomB.programme_item_id))
AND tsA.end > tsB.start
AND roomA.programme_item_id <> roomB.programme_item_id
EOS

ITEM_CONFLICT_QUERY_PT2 = <<"EOS"
) as Conflicts
where room.id = Conflicts.roomA
AND S.id = progA
AND SB.id = progB
EOS
  
end
