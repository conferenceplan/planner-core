class ProgramPlannerController < PlannerController
  include ProgramPlannerHelper
  
  def index
  end

  def getRoomControl
    @roomListing = Room.all(:order => 'venues.name DESC, rooms.name ASC', :joins => :venue) 

    respond_to do |format|
      format.html { render :layout => 'plain' }
      format.xml
    end
  end
  
  #
  # Get the rooms and times for a given day
  # order by room and time
  #
  def list
    j = ActiveSupport::JSON
    rooms = j.decode params[:rooms] if params[:rooms] # the rooms that we want to show
    conditions = ['rooms.id in (?)', rooms] if rooms && (rooms.size > 0)
    @day = params[:day] # Day
    @roomListing = Room.all(:order => 'venues.name DESC, rooms.name ASC', :joins => :venue, :conditions => conditions) # use room_item_assignments.day(@day) to filter list of assignments by day
    
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
    if !params[:cancel]
      @item = ProgrammeItem.find(params[:itemid])
      @room = Room.find(params[:roomid])
      @day = params[:day]
      time = params[:time] # The start time in hours and minutes for the programme item
    
      addItemToRoomAndTime(@item, @room, @day, time)
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
    reserved = PersonItemRole.find_by_name("Reserved")
    
    @day = params[:day]
    query = CONFLICT_QUERY_PT1 + "AND (progA.role_id != " + reserved.id.to_s + " AND progB.role_id != " + reserved.id.to_s + ")"
    
    
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
    
    query = EXCLUDED_ITEM_QUERY_PT1 + "AND (progB.role_id != " + reserved.id.to_s + ")"

    if (@day)
      query += 'AND roomA.day = ' + @day.to_s+ ' AND roomB.day = ' + @day.to_s
    end
    query += EXCLUDED_ITEM_QUERY_PT2
    @excludedItemConflicts = ActiveRecord::Base.connection.select_rows(query)
    
    query = EXCLUDED_TIME_QUERY_PT1
    if (@day)
      query += 'AND roomB.day = ' + @day.to_s
    end
    query += EXCLUDED_TIME_QUERY_PT2
    @excludedTimeConflicts = ActiveRecord::Base.connection.select_rows(query)
    
    query = AVAILABLE_TIME_CONFLICT_QUERY_PT1
    if (@day)
      query += 'AND roomB.day = ' + @day.to_s
    end
    
    query += AVAILABLE_TIME_CONFLICTS_QUERY_PT2
    @availableTimeConflicts = ActiveRecord::Base.connection.select_rows(query)
    
    query = BACK_TO_BACK_QUERY_PT1
    if (@day)
      query += 'AND roomB.day = ' + @day.to_s
    end
    query += BACK_TO_BACK_QUERY_PT2
    @backtobackConflicts = ActiveRecord::Base.connection.select_rows(query)
    
    respond_to do |format|
      format.html { 
        if @day
          render :layout => 'plain'
        end
      }
    end
  end
  
  protected
  
  
CONFLICT_QUERY_PT1 = <<"EOS"
  select 
  R.id as id, R.name as name,
  P.id as person_id, P.first_name as person_first_name, P.last_name, 
  S.id as item_id, S.title as item_name, Conflicts.startA as item_start,
  RB.id as conflict_room_id, RB.name as conflict_room_name,
  SB.id as conflict_item_id, SB.title as conflict_item_title,
  Conflicts.startB as conflict_start
  from people P, rooms R, programme_items S,
  rooms RB, programme_items SB, 
   (select progA.person_id as pidA, progB.person_id as pidB, 
   roomA.room_id as roomA, progA.programme_item_id as progA, 
   progA.role_id as roleA, progB.role_id as roleB, tsA.start as startA, tsA.end as endA,
   roomB.room_id as roomB, progB.programme_item_id as progB, tsB.start as startB, tsB.end as endB
   from programme_item_assignments progA, room_item_assignments roomA, time_slots tsA,
   programme_item_assignments progB, room_item_assignments roomB, time_slots tsB
   where
   roomA.programme_item_id = progA.programme_item_id AND roomA.time_slot_id = tsA.id AND
   roomB.programme_item_id = progB.programme_item_id AND roomB.time_slot_id = tsB.id AND
   (tsA.start < tsB.start OR (tsA.start = tsB.start AND progA.programme_item_id < progB.programme_item_id))
  AND tsA.end > tsB.start
  AND progA.programme_item_id <> progB.programme_item_id
  AND progA.person_id = progB.person_id
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
select room.id, room.name as name, 
S.id as item_id, S.title as item_name,
SB.id as conflict_item_id, SB.title as conflict_item_name,
Conflicts.startA as item_start,
Conflicts.startB as conflict_start
from
rooms room, programme_items S, programme_items SB,
(select 
   roomA.room_id as roomA, roomA.programme_item_id as progA, tsA.start as startA, tsA.end as endA,
   roomB.room_id as roomB, roomB.programme_item_id as progB, tsB.start as startB, tsB.end as endB
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
  
EXCLUDED_ITEM_QUERY_PT1 = <<"EOS"
  select 
  R.id as id, R.name as name,
  P.id as person_id, P.first_name as person_first_name, P.last_name, 
  S.id as item_id, S.title as item_name, Conflicts.startA as item_start,
  RB.id as conflict_room_id, RB.name as conflict_room_name,
  SB.id as conflict_item_id, SB.title as conflict_item_title,
  Conflicts.startB as conflict_start
  from people P, rooms R, programme_items S,
  rooms RB, programme_items SB, 
   (select exA.person_id as pidA, progB.person_id as pidB, 
   roomA.room_id as roomA, exA.excludable_id as progA, 
   tsA.start as startA, tsA.end as endA,
   roomB.room_id as roomB, progB.programme_item_id as progB, tsB.start as startB, tsB.end as endB
   from exclusions exA, room_item_assignments roomA, time_slots tsA,
   programme_item_assignments progB, room_item_assignments roomB, time_slots tsB
   where
   (exA.excludable_type = 'ProgrammeItem' AND roomA.programme_item_id = exA.excludable_id AND roomA.time_slot_id = tsA.id) AND
   (roomB.programme_item_id = progB.programme_item_id AND roomB.time_slot_id = tsB.id) AND
    ((tsB.start >= tsA.start AND tsA.end > tsB.start) OR
     (tsB.start < tsA.start AND tsB.end > tsA.start))
  AND exA.excludable_id <> progB.programme_item_id
  AND exA.person_id = progB.person_id
EOS
  
EXCLUDED_ITEM_QUERY_PT2 = <<"EOS"
  ) as Conflicts
  where
  R.id = Conflicts.roomA AND
  P.id = Conflicts.pidA AND
  S.id = Conflicts.progA AND
  RB.id = Conflicts.roomB AND
  SB.id = Conflicts.progB
  order by P.id
EOS

EXCLUDED_TIME_QUERY_PT1 = <<"EOS"
 select 
  R.id as id, R.name as name,
  P.id as person_id, P.first_name as person_first_name, P.last_name, 
  S.id as item_id, S.title as item_name, Conflicts.startB as item_start,
  Conflicts.startA as period_start, Conflicts.endA as period_end
  from people P, rooms R, programme_items S,
   (select exA.person_id as pidA, progB.person_id as pidB, 
   tsA.start as startA, tsA.end as endA,
   roomB.room_id as roomB, progB.programme_item_id as progB, tsB.start as startB, tsB.end as endB
   from exclusions exA, time_slots tsA,
   programme_item_assignments progB, room_item_assignments roomB, time_slots tsB
   where
   (exA.excludable_type = 'TimeSlot' AND exA.excludable_id = tsA.id) AND
   (exA.person_id = progB.person_id) AND
   (roomB.programme_item_id = progB.programme_item_id AND roomB.time_slot_id = tsB.id) AND
    ((tsB.start >= tsA.start AND tsA.end > tsB.start) OR
     (tsB.start < tsA.start AND tsB.end > tsA.start)) 
EOS

EXCLUDED_TIME_QUERY_PT2 = <<"EOS"
) as Conflicts
  where
  R.id = Conflicts.roomB AND
  S.id = Conflicts.progB AND
  P.id = Conflicts.pidA
  order by P.id;
EOS

AVAILABLE_TIME_CONFLICT_QUERY_PT1 = <<"EOS"
select 
  R.id as id, R.name as name,
  P.id as person_id, P.first_name as person_first_name, P.last_name, 
  S.id as item_id, S.title as item_name, Conflicts.startB as item_start,
  Conflicts.startA as period_start, Conflicts.endA as period_end
  from people P, rooms R, programme_items S,
   (select availA.person_id as pidA, progB.person_id as pidB, 
   availA.start_time as startA, availA.end_time as endA,
   roomB.room_id as roomB, progB.programme_item_id as progB, tsB.start as startB, tsB.end as endB
   from available_dates availA, 
   programme_item_assignments progB, room_item_assignments roomB, time_slots tsB
   where
   (availA.person_id = progB.person_id) AND
   (roomB.programme_item_id = progB.programme_item_id AND roomB.time_slot_id = tsB.id) AND
    ((availA.start_time > tsB.start) OR (availA.start_time > tsB.end) OR
     (availA.end_time < tsB.start) OR (availA.end_time < tsB.end)) 
EOS

AVAILABLE_TIME_CONFLICTS_QUERY_PT2 = <<"EOS"
) as Conflicts
  where
  R.id = Conflicts.roomB AND
  S.id = Conflicts.progB AND
  P.id = Conflicts.pidA
  order by P.id;
EOS

BACK_TO_BACK_QUERY_PT1 = <<"EOS"
  select 
  R.id as id, R.name as name,
  P.id as person_id, P.first_name as person_first_name, P.last_name, 
  S.id as item_id, S.title as item_name, Conflicts.startA as item_start,
  RB.id as conflict_room_id, RB.name as conflict_room_name,
  SB.id as conflict_item_id, SB.title as conflict_item_title,
  Conflicts.startB as conflict_start
  from people P, rooms R, programme_items S,
  rooms RB, programme_items SB, 
   (select progA.person_id as pidA, progB.person_id as pidB, 
   roomA.room_id as roomA, progA.programme_item_id as progA, 
   progA.role_id as roleA, progB.role_id as roleB, tsA.start as startA, tsA.end as endA,
   roomB.room_id as roomB, progB.programme_item_id as progB, tsB.start as startB, tsB.end as endB
   from programme_item_assignments progA, room_item_assignments roomA, time_slots tsA,
   programme_item_assignments progB, room_item_assignments roomB, time_slots tsB
   where
   roomA.programme_item_id = progA.programme_item_id AND roomA.time_slot_id = tsA.id AND
   roomB.programme_item_id = progB.programme_item_id AND roomB.time_slot_id = tsB.id AND
   (tsA.end = tsB.start)
  AND progA.programme_item_id <> progB.programme_item_id
  AND progA.person_id = progB.person_id
EOS
  
BACK_TO_BACK_QUERY_PT2 = <<"EOS"
  ) as Conflicts
  where
  R.id = Conflicts.roomA AND
  P.id = Conflicts.pidA AND
  S.id = Conflicts.progA AND
  RB.id = Conflicts.roomB AND
  SB.id = Conflicts.progB
  order by P.id,Conflicts.startA
EOS

end
