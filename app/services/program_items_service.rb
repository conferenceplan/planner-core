#
#
#
module ProgramItemsService
  
  def self.countItems(filters = nil, extraClause = nil, nameSearch=nil, context=nil, tags = nil)
    args = genArgsForSql(nameSearch, filters, extraClause)
    tagquery = DataService.genTagSql(context, tags)
    
    if tagquery.empty?
      ProgrammeItem.count args
    else
      eval "ProgrammeItem#{tagquery}.count :all, " + args.inspect
    end
  end
  
  def self.findItems(rows=15, page=1, index='last_name', sort_order='asc', filters = nil, extraClause = nil, nameSearch=nil, context=nil, tags = nil)
    args = genArgsForSql(nameSearch, filters, extraClause)
    tagquery = DataService.genTagSql(context, tags)
    
    offset = (page - 1) * rows.to_i
    args.merge!(:offset => offset, :limit => rows)
    
    if (index != nil && index != "")
       args.merge!(:offset => offset, :limit => rows, :order => index + " " + sort_order)
    else
       args.merge!(:offset => offset, :limit => rows, :order => "time_slots.start asc")
    end

    
    # if index
      # args.merge!(:order => index + " " + sort_order)
    # end
    
    if tagquery.empty?
      items = ProgrammeItem.find :all, args
    else
      items = eval "ProgrammeItem#{tagquery}.find :all, " + args.inspect
    end
  end
  
  #
  #
  #
  def self.findProgramItemsForPerson(person)
    ProgrammeItemAssignment.all(
        :conditions => ['(programme_item_assignments.person_id = ?) AND (programme_item_assignments.role_id in (?))', 
            person.id, 
            [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id,PersonItemRole['Invisible'].id]],
            :include => {:programmeItem => [{:programme_item_assignments => {:person => [:pseudonym, :email_addresses]}}, :equipment_types, {:room => :venue}, :time_slot]},
            :order => "time_slots.start asc"
    )
  end
  
  #
  #
  #
  def self.getNumberOfItems
    return ProgrammeItem.count
  end
  
  def self.getNumberOfScheduledItems
    return RoomItemAssignment.count
  end
  
  def self.getNumberOfConflicts(day = nil)
    return getNbrItemConflicts(day) + getNbrRoomConflicts(day) + getNbrExcludedItemConflicts(day) + 
              getNbrExcludedTimeConflicts(day) + getNbrAvailabilityConficts(day) + getNbrBackToBackConflicts(day)
  end

  #
  # TODO - changethe select_rows to select_all so we have column names and less dependent on positional info for the output
  #
  
  #
  #
  #
  def self.getNbrItemConflicts(day = nil)
    query = "select count(*) from (" + itemConflictSql(day) + ") res"
    
    res = ActiveRecord::Base.connection.select_rows(query)
    
    res[0][0].to_i
  end
  
  def self.getItemConflicts(day = nil)
    query = itemConflictSql(day) 

    ActiveRecord::Base.connection.select_rows(query)
  end
  
  def self.getNbrRoomConflicts(day = nil)
    query = "select count(*) from (" + roomConflictsSql(day) + ") res"
    
    res = ActiveRecord::Base.connection.select_rows(query)
    
    res[0][0].to_i
  end
  
  def self.getRoomConflicts(day = nil)
    ActiveRecord::Base.connection.select_rows(roomConflictsSql(day))
  end
  
  def self.getNbrExcludedItemConflicts(day = nil)
    query = "select count(*) from (" + excludedItemConflictsSql(day) + ") res"
    
    res = ActiveRecord::Base.connection.select_rows(query)
    
    res[0][0].to_i
  end
  
  def self.getExcludedItemConflicts(day = nil)
    ActiveRecord::Base.connection.select_rows(excludedItemConflictsSql(day))
  end
  
  def self.getNbrExcludedTimeConflicts(day = nil)
    query = "select count(*) from (" + excludedTimeConflictsSql(day) + ") res"
    
    res = ActiveRecord::Base.connection.select_rows(query)
    
    res[0][0].to_i
  end
  
  def self.getExcludedTimeConflicts(day = nil)
    ActiveRecord::Base.connection.select_rows(excludedTimeConflictsSql(day))
  end
  
  def self.getNbrAvailabilityConficts(day = nil)
    query = "select count(*) from (" + availabilityConfictsSql(day) + ") res"
    
    res = ActiveRecord::Base.connection.select_rows(query)
    
    res[0][0].to_i
  end
  
  def self.getAvailabilityConficts(day = nil)
    ActiveRecord::Base.connection.select_rows(availabilityConfictsSql(day))
  end
  
  def self.getNbrBackToBackConflicts(day = nil)
    query = "select count(*) from (" + backToBackConflictsSql(day) + ") res"
    
    res = ActiveRecord::Base.connection.select_rows(query)
    
    res[0][0].to_i
  end
  
  def self.getBackToBackConflicts(day = nil)
    ActiveRecord::Base.connection.select_rows(backToBackConflictsSql(day))
  end
  
protected

  def self.genArgsForSql(nameSearch, filters, extraClause)
    clause = DataService.createWhereClause(filters, 
                  ['format_id','pub_reference_number'],
                  ['format_id','pub_reference_number'], 'programme_items.title')

    # add the name search of the title
    if nameSearch
      st = DataService.getFilterData( filters, 'programme_items.title' )
      if (st)
        clause = DataService.addClause(clause,'programme_items.title like ?','%' + st + '%')
      end
    end
    
    # TODO - add these
    # if ignoreScheduled
      # clause = addClause( clause, 'room_item_assignments.programme_item_id is null', nil )
    # end
    # if ignorePending
      # clause = addClause( clause, 'pending_publication_items.programme_item_id is null', nil )
      # clause = addClause( clause, 'programme_items.print = true', nil )
    # end

    args = { :conditions => clause }
    
    args.merge!( :joins => 'LEFT JOIN room_item_assignments ON room_item_assignments.programme_item_id = programme_items.id ' +
                           'LEFT JOIN time_slots on time_slots.id = room_item_assignments.time_slot_id ' +
                           'LEFT JOIN pending_publication_items on pending_publication_items.programme_item_id = programme_items.id ' )

    args
  end

  def self.itemConflictSql(day = nil)
    query = @@CONFLICT_QUERY_PT1 
    query += "AND (progA.role_id != " + PersonItemRole['Reserved'].id.to_s + " AND progB.role_id != " + PersonItemRole['Reserved'].id.to_s + ")"
    query += 'AND roomA.day = ' + day.to_s+ ' AND roomB.day = ' + day.to_s if day
    query += @@CONFLICT_QUERY_PT2
    
    query
  end
  
  def self.roomConflictsSql(day = nil)
    query = @@ITEM_CONFLICT_QUERY_PT1
    query += 'AND roomA.day = ' + day.to_s+ ' AND roomB.day = ' + day.to_s if day
    query += @@ITEM_CONFLICT_QUERY_PT2
    
    query
  end
  
  def self.excludedItemConflictsSql(day = nil)
    query = @@EXCLUDED_ITEM_QUERY_PT1 + "AND (progB.role_id != " + PersonItemRole['Reserved'].id.to_s + ")"
    query += 'AND roomA.day = ' + day.to_s+ ' AND roomB.day = ' + day.to_s if day
    query += @@EXCLUDED_ITEM_QUERY_PT2
    
    query
  end
  
  def self.excludedTimeConflictsSql(day = nil)
    query = @@EXCLUDED_TIME_QUERY_PT1 + "AND (progB.role_id != " + PersonItemRole['Reserved'].id.to_s + ")"
    query += 'AND roomB.day = ' + day.to_s if day
    query += @@EXCLUDED_TIME_QUERY_PT2
    
    query
  end
  
  def self.availabilityConfictsSql(day = nil)
    query = @@AVAILABLE_TIME_CONFLICT_QUERY_PT1 + "AND (progB.role_id != " + PersonItemRole['Reserved'].id.to_s + ")"
    query += 'AND roomB.day = ' + day.to_s if day
    query += @@AVAILABLE_TIME_CONFLICTS_QUERY_PT2
    
    query
  end
  
  def self.backToBackConflictsSql(day = nil)
    query = @@BACK_TO_BACK_QUERY_PT1 
    query += "AND (progA.role_id != " + PersonItemRole['Reserved'].id.to_s + " AND progB.role_id != " + PersonItemRole['Reserved'].id.to_s + ")"
    query += 'AND roomB.day = ' + day.to_s if day
    query += @@BACK_TO_BACK_QUERY_PT2
    
    query
  end

@@CONFLICT_QUERY_PT1 = <<"EOS"
  select 
  R.id as id, R.name as name,
  P.id as person_id, P.first_name as person_first_name, P.last_name, 
  S.id as item_id, S.title as item_name, Conflicts.roleA item_role,
  Conflicts.startA as item_start,
  RB.id as conflict_room_id, RB.name as conflict_room_name,
  SB.id as conflict_item_id, SB.title as conflict_item_title, Conflicts.roleB as conflict_item_role,
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
  
@@CONFLICT_QUERY_PT2 = <<"EOS"
  ) as Conflicts
  where
  R.id = Conflicts.roomA AND
  P.id = Conflicts.pidA AND
  S.id = Conflicts.progA AND
  RB.id = Conflicts.roomB AND
  SB.id = Conflicts.progB
  order by P.id
EOS

@@ITEM_CONFLICT_QUERY_PT1 = <<"EOS"
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

@@ITEM_CONFLICT_QUERY_PT2 = <<"EOS"
) as Conflicts
where room.id = Conflicts.roomA
AND S.id = progA
AND SB.id = progB
EOS
  
@@EXCLUDED_ITEM_QUERY_PT1 = <<"EOS"
  select 
  R.id as id, R.name as name,
  P.id as person_id, P.first_name as person_first_name, P.last_name, 
  S.id as item_id, S.title as item_name, Conflicts.startA as item_start,
  RB.id as conflict_room_id, RB.name as conflict_room_name,
  SB.id as conflict_item_id, SB.title as conflict_item_title,
  Conflicts.startB as conflict_start,
  Conflicts.roleB item_role
  from people P, rooms R, programme_items S,
  rooms RB, programme_items SB, 
   (select exA.person_id as pidA, progB.person_id as pidB, 
   roomA.room_id as roomA, exA.excludable_id as progA, 
   tsA.start as startA, tsA.end as endA,
   roomB.room_id as roomB, progB.programme_item_id as progB, tsB.start as startB, tsB.end as endB,
   progB.role_id as roleB
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
  
@@EXCLUDED_ITEM_QUERY_PT2 = <<"EOS"
  ) as Conflicts
  where
  R.id = Conflicts.roomA AND
  P.id = Conflicts.pidA AND
  S.id = Conflicts.progA AND
  RB.id = Conflicts.roomB AND
  SB.id = Conflicts.progB
  order by P.id
EOS

@@EXCLUDED_TIME_QUERY_PT1 = <<"EOS"
 select 
  R.id as id, R.name as name,
  P.id as person_id, P.first_name as person_first_name, P.last_name, 
  S.id as item_id, S.title as item_name, Conflicts.startB as item_start,
  Conflicts.startA as period_start, Conflicts.endA as period_end,
  Conflicts.roleB item_role
  from people P, rooms R, programme_items S,
   (select exA.person_id as pidA, progB.person_id as pidB, 
   tsA.start as startA, tsA.end as endA,
   roomB.room_id as roomB, progB.programme_item_id as progB, tsB.start as startB, tsB.end as endB,
   progB.role_id as roleB
   from exclusions exA, time_slots tsA,
   programme_item_assignments progB, room_item_assignments roomB, time_slots tsB
   where
   (exA.excludable_type = 'TimeSlot' AND exA.excludable_id = tsA.id) AND
   (exA.person_id = progB.person_id) AND
   (roomB.programme_item_id = progB.programme_item_id AND roomB.time_slot_id = tsB.id) AND
    ((tsB.start >= tsA.start AND tsA.end > tsB.start) OR
     (tsB.start < tsA.start AND tsB.end > tsA.start)) 
EOS

@@EXCLUDED_TIME_QUERY_PT2 = <<"EOS"
) as Conflicts
  where
  R.id = Conflicts.roomB AND
  S.id = Conflicts.progB AND
  P.id = Conflicts.pidA
  order by P.id
EOS

@@AVAILABLE_TIME_CONFLICT_QUERY_PT1 = <<"EOS"
select 
  R.id as id, R.name as name,
  P.id as person_id, P.first_name as person_first_name, P.last_name, 
  S.id as item_id, S.title as item_name, Conflicts.startB as item_start,
  Conflicts.startA as period_start, Conflicts.endA as period_end,
  Conflicts.roleB item_role
  from people P, rooms R, programme_items S,
   (select availA.person_id as pidA, progB.person_id as pidB, 
   availA.start_time as startA, availA.end_time as endA,
   roomB.room_id as roomB, progB.programme_item_id as progB, tsB.start as startB, tsB.end as endB,
   progB.role_id as roleB
   from available_dates availA, 
   programme_item_assignments progB, room_item_assignments roomB, time_slots tsB
   where
   (availA.person_id = progB.person_id) AND
   (roomB.programme_item_id = progB.programme_item_id AND roomB.time_slot_id = tsB.id) AND
    ((availA.start_time > tsB.start) OR (availA.start_time > tsB.end) OR
     (availA.end_time < tsB.start) OR (availA.end_time < tsB.end)) 
EOS

@@AVAILABLE_TIME_CONFLICTS_QUERY_PT2 = <<"EOS"
) as Conflicts
  where
  R.id = Conflicts.roomB AND
  S.id = Conflicts.progB AND
  P.id = Conflicts.pidA
  order by P.id
EOS

@@BACK_TO_BACK_QUERY_PT1 = <<"EOS"
  select 
  R.id as id, R.name as name,
  P.id as person_id, P.first_name as person_first_name, P.last_name, 
  S.id as item_id, S.title as item_name, Conflicts.startA as item_start,
  RB.id as conflict_room_id, RB.name as conflict_room_name,
  SB.id as conflict_item_id, SB.title as conflict_item_title,
  Conflicts.startB as conflict_start,
  Conflicts.roleA item_role,
  Conflicts.roleB conflict_item_role
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
  
@@BACK_TO_BACK_QUERY_PT2 = <<"EOS"
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
