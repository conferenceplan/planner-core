#
#
#
module ProgramItemsService
  
  def self.findAllItems

    ProgrammeItem.includes([:time_slot, :room_item_assignment, :programme_item_assignments, {:people => :pseudonym}, {:room => [:venue]}]).
                            order("time_slots.start ASC, programme_items.title")
    
  end
  
  def self.assign_reference_numbers(increment = 3)
      items = ProgrammeItem.all(:include => [:time_slot, :room_item_assignment, {:people => :pseudonym}, {:room => [:venue]} ],
                                                 :order => 'time_slots.start ASC, venues.name DESC, rooms.name ASC',
                                                 :conditions => 'programme_items.print = true')
                                                 
      itemNumber = increment
      base = 1000
      current_day = 0
      items.each do |item|
        if (item.room_item_assignment != nil)
          if item.room_item_assignment.day != current_day
            current_day = item.room_item_assignment.day
            base = 1000 * (current_day + 1)
            itemNumber = increment
          end
          item.pub_reference_number = base + itemNumber
          item.save!
          itemNumber = itemNumber+increment
        end
      end
  end
  
  #
  #
  #
  def self.countItems(filters = nil, extraClause = nil, nameSearch=nil, context=nil, tags = nil, ignoreScheduled = false, page_to = nil)
    args = genArgsForSql(nameSearch, filters, extraClause, ignoreScheduled, page_to)
    tagquery = DataService.genTagSql(context, tags)
    
    args.merge!(:order => "time_slots.start asc, programme_items.title asc")

    if tagquery.empty?
      ProgrammeItem.count args
    else
      ProgrammeItem.tagged_with(*tagquery).uniq.count( :all, args )
    end
  end
  
  def self.findItems(rows=15, page=1, index=nil, sort_order='asc', filters = nil, extraClause = nil, nameSearch=nil, context=nil, tags = nil, ignoreScheduled = false)
    args = genArgsForSql(nameSearch, filters, extraClause, ignoreScheduled)
    tagquery = DataService.genTagSql(context, tags)
    
    offset = (page - 1) * rows.to_i
    offset = 0 if offset < 0
    # args.merge!(:offset => offset, :limit => rows)
    
    if (index != nil && index != "")
       args.merge!(:offset => offset, :limit => rows, :order => index + " " + sort_order)
    else
       args.merge!(:offset => offset, :limit => rows, :order => "time_slots.start asc, programme_items.title asc")
    end

    # if index
      # args.merge!(:order => index + " " + sort_order)
    # end
    
    if tagquery.empty?
      items = ProgrammeItem.includes(:programme_item_assignments).find :all, args
    else
      items = ProgrammeItem.tagged_with(*tagquery).uniq.includes(:programme_item_assignments).find :all, args
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
  #
  #
  def self.getNbrItemConflicts(day = nil)
    query = "select count(*) as count from (" + itemConflictSql(day) + ") res"
    
    res = ActiveRecord::Base.connection.select_one(query)
    
    res['count'].to_i
  end
  
  def self.getItemConflicts(day = nil)
    query = itemConflictSql(day)

    ActiveRecord::Base.connection.select_all(query)
  end
  
  def self.getNbrRoomConflicts(day = nil)
    query = "select count(*) as count from (" + roomConflictsSql(day) + ") res"
    
    res = ActiveRecord::Base.connection.select_one(query)
    
    res['count'].to_i
  end
  
  def self.getRoomConflicts(day = nil)
    ActiveRecord::Base.connection.select_all(roomConflictsSql(day))
  end
  
  def self.getNbrExcludedItemConflicts(day = nil)
    query = "select count(*) as count from (" + excludedItemConflictsSql(day) + ") res"
    
    res = ActiveRecord::Base.connection.select_one(query)
    
    res['count'].to_i
  end
  
  def self.getExcludedItemConflicts(day = nil)
    ActiveRecord::Base.connection.select_all(excludedItemConflictsSql(day))
  end
  
  def self.getNbrExcludedTimeConflicts(day = nil)
    query = "select count(*) as count from (" + excludedTimeConflictsSql(day) + ") res"
    
    res = ActiveRecord::Base.connection.select_one(query)
    
    res['count'].to_i
  end
  
  def self.getExcludedTimeConflicts(day = nil)
    ActiveRecord::Base.connection.select_all(excludedTimeConflictsSql(day))
  end
  
  def self.getNbrAvailabilityConficts(day = nil)
    query = "select count(*) as count from (" + availabilityConfictsSql(day) + ") res"
    
    res = ActiveRecord::Base.connection.select_one(query)
    
    res['count'].to_i
  end
  
  def self.getAvailabilityConficts(day = nil)
    ActiveRecord::Base.connection.select_all(availabilityConfictsSql(day))
  end
  
  def self.getNbrBackToBackConflicts(day = nil)
    query = "select count(*) as count from (" + backToBackConflictsSql(day) + ") res"
    
    res = ActiveRecord::Base.connection.select_one(query)
    
    res['count'].to_i
  end
  
  def self.getBackToBackConflicts(day = nil)
    ActiveRecord::Base.connection.select_all(backToBackConflictsSql(day))
  end
  
protected

  def self.genArgsForSql(nameSearch, filters, extraClause, ignoreScheduled, page_to = nil)
    clause = DataService.createWhereClause(filters, 
                  ['format_id','pub_reference_number'],
                  ['format_id','pub_reference_number'], ['programme_items.title'])

    if ignoreScheduled
      clause = DataService.addClause( clause, 'room_item_assignments.programme_item_id is null', nil )
    end
    # add the name search of the title
    if nameSearch
      st = DataService.getFilterData( filters, 'programme_items.title' )
      if (st)
        clause = DataService.addClause(clause,'programme_items.title like ?','%' + st + '%')
      end
    end
    
    # TODO - add these
    # if ignorePending
      # clause = addClause( clause, 'pending_publication_items.programme_item_id is null', nil )
      # clause = addClause( clause, 'programme_items.print = true', nil )
    # end
    
    # TODO - assumed that the new creation does not have a time slot. Need to change
    clause = DataService.addClause( clause, 'programme_items.title <= ? AND time_slots.start is null', page_to) if page_to

    args = { :conditions => clause }
    
    args.merge!( :joins => 'LEFT JOIN room_item_assignments ON room_item_assignments.programme_item_id = programme_items.id ' +
                           'LEFT JOIN time_slots on time_slots.id = room_item_assignments.time_slot_id ' )

    args
  end

  def self.itemConflictSql(day = nil)
    
    conflict_exceptions = Arel::Table.new(:conflict_exceptions)

    assignments = Arel::Table.new(:programme_item_assignments)
    room_assignments = Arel::Table.new(:room_item_assignments)
    time_slots = Arel::Table.new(:time_slots)

    assignments_alias = assignments.alias
    room_assignments_alias = room_assignments.alias
    time_slots_alias = time_slots.alias

    rooms = Arel::Table.new(:rooms)
    people = Arel::Table.new(:people)
    items = Arel::Table.new(:programme_items)

    rooms_alias = rooms.alias
    people_alias = people.alias
    items_alias = items.alias

    assignment_attrs = [
      rooms[:id].as('room_id'), rooms[:name].as('room_name'), 
      people[:id].as('person_id'), people[:first_name].as('person_first_name'), people[:last_name].as('person_last_name'),
      items[:id].as('item_id'), items[:title].as('item_name'), assignments[:role_id].as('item_role'), 
      time_slots[:start].as('item_start'),
      rooms_alias[:id].as('conflict_room_id'), rooms_alias[:name].as('conflict_room_name'), 
      items_alias[:id].as('conflict_item_id'), items_alias[:title].as('conflict_item_title'), 
      assignments_alias[:role_id].as('conflict_item_role'), time_slots_alias[:start].as('conflict_start')
      ]

    query = assignments.project(*assignment_attrs).
                                      join(room_assignments).on(room_assignments[:programme_item_id].eq(assignments[:programme_item_id])).
                                      join(time_slots).on(room_assignments[:time_slot_id].eq(time_slots[:id])).
                                      join(assignments_alias).on(assignments[:id].lt(assignments_alias[:id])).
                                      join(room_assignments_alias).on(room_assignments_alias[:programme_item_id].eq(assignments_alias[:programme_item_id])).
                                      join(time_slots_alias).on(room_assignments_alias[:time_slot_id].eq(time_slots_alias[:id])).
                                      where(
                                          time_slots[:start].lt(time_slots_alias[:start]).
                                          or(time_slots[:start].eq(time_slots_alias[:start])).
                                          and(time_slots[:end].gt(time_slots_alias[:start])).
                                          and(assignments[:programme_item_id].not_eq(assignments_alias[:programme_item_id])).
                                          and(assignments[:person_id].eq(assignments_alias[:person_id])).
                                          and(assignments[:role_id].not_eq(PersonItemRole['Reserved'].id).and(assignments_alias[:role_id].not_eq(PersonItemRole['Reserved'].id)))
                                      )

    query = query.where(room_assignments[:day].eq(day.to_s).and(room_assignments_alias[:day].eq(day.to_s))) if day
  
    query = query.join(conflict_exceptions, Arel::Nodes::OuterJoin).
                                                  on(conflict_exceptions[:affected].eq(assignments[:person_id]).
                                                      and(conflict_exceptions[:src1].eq(assignments[:programme_item_id])).
                                                      and(conflict_exceptions[:src2].eq(assignments_alias[:programme_item_id]))
                                                    ).where(
                                                      conflict_exceptions[:id].eq(nil)
                                                    )

    query = query.
                                join(rooms).on(rooms[:id].eq(room_assignments[:room_id])).
                                join(people).on(people[:id].eq(assignments[:person_id])).
                                join(items).on(items[:id].eq(assignments[:programme_item_id])).
                                join(rooms_alias).on(rooms_alias[:id].eq(room_assignments_alias[:room_id])).
                                join(people_alias).on(people_alias[:id].eq(assignments_alias[:person_id])).
                                join(items_alias).on(items_alias[:id].eq(assignments_alias[:programme_item_id]))

    query = query.where(self.constraints())
    
    query.to_sql
  end
    
  def self.roomConflictsSql(day = nil)
    conflict_exceptions = Arel::Table.new(:conflict_exceptions)

    room_assignments = Arel::Table.new(:room_item_assignments)
    time_slots = Arel::Table.new(:time_slots)

    room_assignments_alias = room_assignments.alias
    time_slots_alias = time_slots.alias

    rooms = Arel::Table.new(:rooms)
    items = Arel::Table.new(:programme_items)

    rooms_alias = rooms.alias
    items_alias = items.alias

    assignment_attrs = [
      rooms[:id].as('room_id'), rooms[:name].as('room_name'), 
      items[:id].as('item_id'), items[:title].as('item_name'), 
      time_slots[:start].as('item_start'),
      items_alias[:id].as('conflict_item_id'), items_alias[:title].as('conflict_item_name'), 
      # assignments_alias[:role_id].as('conflict_item_role'), 
      time_slots_alias[:start].as('conflict_start')
      ]

    query = room_assignments.project(*assignment_attrs).
                join(room_assignments_alias).on(room_assignments[:room_id].eq(room_assignments_alias[:room_id])).
                join(time_slots).on(room_assignments[:time_slot_id].eq(time_slots[:id])).
                join(time_slots_alias).on(room_assignments_alias[:time_slot_id].eq(time_slots_alias[:id])).
                where(
                  time_slots[:start].lt(time_slots_alias[:start]).or(
                    time_slots[:start].eq(time_slots_alias[:start]).and(
                      room_assignments[:programme_item_id].lt(room_assignments_alias[:programme_item_id])
                    )
                  ).and(
                    time_slots[:end].gt(time_slots_alias[:start])
                  ).and(
                    room_assignments[:programme_item_id].not_eq(room_assignments_alias[:programme_item_id])
                  )
                )
                          
    query = query.where(room_assignments[:day].eq(day.to_s).and(room_assignments_alias[:day].eq(day.to_s))) if day

    query = query.join(conflict_exceptions, Arel::Nodes::OuterJoin).
                  on(conflict_exceptions[:affected].eq(room_assignments[:id]).
                      and(conflict_exceptions[:src1].eq(room_assignments[:programme_item_id])).
                      and(conflict_exceptions[:src2].eq(room_assignments_alias[:programme_item_id]))
                    ).where(
                      conflict_exceptions[:id].eq(nil)
                    )

    query = query.join(rooms).on(rooms[:id].eq(room_assignments[:room_id])).
                  join(items).on(items[:id].eq(room_assignments[:programme_item_id])).
                  join(rooms_alias).on(rooms_alias[:id].eq(room_assignments_alias[:room_id])).
                  join(items_alias).on(items_alias[:id].eq(room_assignments_alias[:programme_item_id]))

    query = query.where(self.constraints()).take(1000) # TODO - we need paging in the results

    query.to_sql
  end

  def self.excludedItemConflictsSql(day = nil)
    conflict_exceptions = Arel::Table.new(:conflict_exceptions)

    people = Arel::Table.new(:people)
    exclusions = Arel::Table.new(:exclusions)

    assignments = Arel::Table.new(:programme_item_assignments)
    room_assignments = Arel::Table.new(:room_item_assignments)
    time_slots = Arel::Table.new(:time_slots)

    assignments_alias = assignments.alias
    room_assignments_alias = room_assignments.alias
    time_slots_alias = time_slots.alias

    rooms = Arel::Table.new(:rooms)
    people = Arel::Table.new(:people)
    items = Arel::Table.new(:programme_items)
    programme_items = Arel::Table.new(:programme_items)

    rooms_alias = rooms.alias
    items_alias = items.alias
    programme_items_alias = programme_items.alias

    assignment_attrs = [
      rooms[:id].as('room_id'), rooms[:name].as('room_name'), 
      people[:id].as('person_id'), people[:first_name].as('person_first_name'), people[:last_name].as('person_last_name'),
      programme_items[:id].as('item_id'), programme_items[:title].as('item_name'),
      time_slots[:start].as('item_start'),
      rooms_alias[:id].as('conflict_room_id'), rooms_alias[:name].as('conflict_room_name'), 
      items_alias[:id].as('conflict_item_id'), items_alias[:title].as('conflict_item_title'), 
      assignments_alias[:role_id].as('item_role'), time_slots_alias[:start].as('conflict_start')
      ]

    query = people.project(*assignment_attrs).
                          join(exclusions).on(exclusions[:person_id].eq(people[:id]).
                            and(exclusions[:excludable_type].eq('ProgrammeItem'))
                          ).
                          join(room_assignments).on(room_assignments[:programme_item_id].eq(exclusions[:excludable_id])).
                          join(rooms).on(rooms[:id].eq(room_assignments[:room_id])).
                          join(time_slots).on(time_slots[:id].eq(room_assignments[:time_slot_id])).
                          join(programme_items).on(programme_items[:id].eq(exclusions[:excludable_id])).
                          join(assignments_alias).on(assignments_alias[:person_id].eq(people[:id])).
                          join(programme_items_alias).on(programme_items_alias[:id].eq(assignments_alias[:programme_item_id])).
                          join(room_assignments_alias).on(room_assignments_alias[:programme_item_id].eq(assignments_alias[:programme_item_id])).
                          join(rooms_alias).on(rooms_alias[:id].eq(room_assignments_alias[:room_id])).
                          join(time_slots_alias).on(time_slots_alias[:id].eq(room_assignments_alias[:time_slot_id])).
                          where(
                            time_slots_alias[:start].gteq(time_slots[:start]).and(time_slots[:end].gt(time_slots_alias[:start])).or(
                              time_slots_alias[:start].lt(time_slots[:start]).and(time_slots_alias[:end].gt(time_slots[:start]))
                            ).and(
                              exclusions[:excludable_id].not_eq(programme_items_alias[:id])
                            ).and(
                              exclusions[:person_id].eq(assignments_alias[:person_id])
                            )
                          )

    query = query.where(room_assignments[:day].eq(day.to_s).and(room_assignments_alias[:day].eq(day.to_s))) if day

    query = query.join(conflict_exceptions, Arel::Nodes::OuterJoin).
                                                  on(conflict_exceptions[:affected].eq(people[:id]).
                                                      and(conflict_exceptions[:src1].eq(room_assignments_alias[:programme_item_id])).
                                                      and(conflict_exceptions[:src2].eq(room_assignments[:programme_item_id]))
                                                    ).where(
                                                      conflict_exceptions[:id].eq(nil)
                                                    )

    query = query.where(self.constraints())

    query.to_sql
  end

  def self.excludedTimeConflictsSql(day = nil)
    conflict_exceptions = Arel::Table.new(:conflict_exceptions)
    
    people = Arel::Table.new(:people)
    exclusions = Arel::Table.new(:exclusions)

    assignments = Arel::Table.new(:programme_item_assignments)
    room_assignments = Arel::Table.new(:room_item_assignments)
    time_slots = Arel::Table.new(:time_slots)

    assignments_alias = assignments.alias
    room_assignments_alias = room_assignments.alias
    time_slots_alias = time_slots.alias

    rooms = Arel::Table.new(:rooms)
    people = Arel::Table.new(:people)
    programme_items = Arel::Table.new(:programme_items)

    assignment_attrs = [
      rooms[:id].as('room_id'), rooms[:name].as('room_name'),
      people[:id].as('person_id'), people[:first_name].as('person_first_name'), people[:last_name].as('person_last_name'),
      programme_items[:id].as('item_id'), programme_items[:title].as('item_name'),
      time_slots_alias[:start].as('item_start'),
      time_slots[:start].as('period_start'), time_slots[:end].as('period_end'), time_slots[:id].as('period_id'),
      assignments[:role_id].as('item_role')
    ]

    query = time_slots.project(*assignment_attrs).
                          join(exclusions).on(exclusions[:excludable_id].eq(time_slots[:id]).
                            and(exclusions[:excludable_type].eq('TimeSlot'))
                          ).join(time_slots_alias).on(
                            time_slots_alias[:id].not_eq(time_slots[:id]).and(
                              time_slots_alias[:start].gteq(time_slots[:start]).and(time_slots[:end].gt(time_slots_alias[:start])).or(
                                time_slots_alias[:start].lt(time_slots[:start]).and(time_slots_alias[:end].gt(time_slots[:start]))
                              )
                            )
                          ).
                          join(room_assignments).on(room_assignments[:time_slot_id].eq(time_slots_alias[:id])).
                          join(assignments).on(
                              assignments[:programme_item_id].eq(room_assignments[:programme_item_id]).and(
                                  assignments[:role_id].not_eq(PersonItemRole['Reserved'].id)
                                )
                              ).
                          join(people).on(people[:id].eq(assignments[:person_id])).
                          join(rooms).on(rooms[:id].eq(room_assignments[:room_id])).
                          join(programme_items).on(programme_items[:id].eq(room_assignments[:programme_item_id])).
                          where(people[:id].eq(exclusions[:person_id]))

    query = query.where(room_assignments[:day].eq(day.to_s)) if day

    query = query.join(conflict_exceptions, Arel::Nodes::OuterJoin).
                                                  on(conflict_exceptions[:affected].eq(people[:id]).
                                                      and(conflict_exceptions[:src1].eq(room_assignments[:programme_item_id])).
                                                      and(conflict_exceptions[:src2].eq(time_slots[:id]))
                                                    ).where(
                                                      conflict_exceptions[:id].eq(nil)
                                                    ).order(people[:id])
    
    query = query.where(self.constraints())

    query.to_sql
  end

  def self.availabilityConfictsSql(day = nil)
    conflict_exceptions = Arel::Table.new(:conflict_exceptions)
    
    people = Arel::Table.new(:people)
    
    available_dates = Arel::Table.new(:available_dates)

    assignments = Arel::Table.new(:programme_item_assignments)
    room_assignments = Arel::Table.new(:room_item_assignments)
    time_slots = Arel::Table.new(:time_slots)

    rooms = Arel::Table.new(:rooms)
    people = Arel::Table.new(:people)
    programme_items = Arel::Table.new(:programme_items)

    assignment_attrs = [
      rooms[:id].as('room_id'), rooms[:name].as('room_name'),
      people[:id].as('person_id'), people[:first_name].as('person_first_name'), people[:last_name].as('person_last_name'),
      programme_items[:id].as('item_id'), programme_items[:title].as('item_name'),
      time_slots[:start].as('item_start'),
      available_dates[:start_time].as('period_start'), available_dates[:end_time].as('period_end'), available_dates[:id].as('period_id'),
      assignments[:role_id].as('item_role')
    ]

    query = available_dates.project(*assignment_attrs).
                          join(people).on(available_dates[:person_id].eq(people[:id])).
                          join(assignments).on(assignments[:person_id].eq(people[:id]).and(
                            assignments[:role_id].not_eq(PersonItemRole['Reserved'].id)
                          )).
                          join(room_assignments).on(room_assignments[:programme_item_id].eq(assignments[:programme_item_id])).
                          join(rooms).on(rooms[:id].eq(room_assignments[:room_id])).
                          join(programme_items).on(programme_items[:id].eq(assignments[:programme_item_id])).
                          join(time_slots).on(time_slots[:id].eq(room_assignments[:time_slot_id])).
                          where(
                            available_dates[:start_time].gt(time_slots[:start]).or(available_dates[:start_time].gt(time_slots[:end])).
                            or(available_dates[:end_time].lt(time_slots[:start]).or(available_dates[:end_time].lt(time_slots[:end])))
                          )

    query = query.where(room_assignments[:day].eq(day.to_s)) if day

    query = query.join(conflict_exceptions, Arel::Nodes::OuterJoin).
                                                  on(conflict_exceptions[:affected].eq(people[:id]).
                                                      and(conflict_exceptions[:src1].eq(assignments[:programme_item_id])).
                                                      and(conflict_exceptions[:src2].eq(available_dates[:id]))
                                                    ).where(
                                                      conflict_exceptions[:id].eq(nil)
                                                    ).order(people[:id])
    
    query = query.where(self.constraints())

    query.to_sql
  end
  
  def self.backToBackConflictsSql(day = nil)
    conflict_exceptions = Arel::Table.new(:conflict_exceptions)

    people = Arel::Table.new(:people)
    exclusions = Arel::Table.new(:exclusions)

    assignments = Arel::Table.new(:programme_item_assignments)
    room_assignments = Arel::Table.new(:room_item_assignments)
    time_slots = Arel::Table.new(:time_slots)

    assignments_alias = assignments.alias
    room_assignments_alias = room_assignments.alias
    time_slots_alias = time_slots.alias

    rooms = Arel::Table.new(:rooms)
    people = Arel::Table.new(:people)
    items = Arel::Table.new(:programme_items)
    programme_items = Arel::Table.new(:programme_items)

    rooms_alias = rooms.alias
    items_alias = items.alias
    programme_items_alias = programme_items.alias

    assignment_attrs = [
      rooms[:id].as('room_id'), rooms[:name].as('room_name'),
      people[:id].as('person_id'), people[:first_name].as('person_first_name'), people[:last_name].as('person_last_name'),
      programme_items[:id].as('item_id'), programme_items[:title].as('item_name'),
      time_slots[:start].as('item_start'),
      rooms_alias[:id].as('conflict_room_id'), rooms_alias[:name].as('conflict_room_name'), 
      programme_items_alias[:id].as('conflict_item_id'), programme_items_alias[:title].as('conflict_item_title'), 
      time_slots_alias[:start].as('conflict_start'),
      assignments[:role_id].as('item_role'),
      assignments_alias[:role_id].as('conflict_item_role')
      ]
    
    query = room_assignments.project(*assignment_attrs).
                          join(assignments).on(assignments[:programme_item_id].eq(room_assignments[:programme_item_id])).
                          join(time_slots).on(time_slots[:id].eq(room_assignments[:time_slot_id])).
                          join(people).on(people[:id].eq(assignments[:person_id])).
                          join(assignments_alias).on(assignments_alias[:person_id].eq(people[:id])).
                          join(room_assignments_alias).on(room_assignments_alias[:programme_item_id].eq(assignments_alias[:programme_item_id])).
                          join(time_slots_alias).on(time_slots_alias[:id].eq(room_assignments_alias[:time_slot_id])).
                          join(rooms).on(rooms[:id].eq(room_assignments[:room_id])).
                          join(rooms_alias).on(rooms_alias[:id].eq(room_assignments_alias[:room_id])).
                          join(programme_items).on(programme_items[:id].eq(room_assignments[:programme_item_id])).
                          join(programme_items_alias).on(programme_items_alias[:id].eq(room_assignments_alias[:programme_item_id])).
                          where(
                            time_slots[:end].eq(time_slots_alias[:start]).
                            and( assignments[:id].not_eq(assignments_alias[:id]) ).
                            and( assignments[:person_id].eq(assignments_alias[:person_id]) )
                          )

    query = query.where(room_assignments[:day].eq(day.to_s).and(room_assignments_alias[:day].eq(day.to_s))) if day

    query = query.join(conflict_exceptions, Arel::Nodes::OuterJoin).
                                                  on(conflict_exceptions[:affected].eq(people[:id]).
                                                      and(conflict_exceptions[:src1].eq(assignments[:programme_item_id])).
                                                      and(conflict_exceptions[:src2].eq(assignments_alias[:programme_item_id]))
                                                    ).where(
                                                      conflict_exceptions[:id].eq(nil)
                                                    ).order(people[:id])
    
    query = query.where(self.constraints())

    query.to_sql
  end

  def self.constraints(*args)
    true
  end

end
