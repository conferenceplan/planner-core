#
#
#
module ProgramItemsService

  def self.create_item(item_data, format_name)
    format = Format.find_by name: format_name # find format (or create if does not exist)
    if !format
      format = Format.create(name: format_name)
      format.save!
    end

    item_data[:format_id] = format.id
    
    item = ProgrammeItem.create(item_data)
    
    item
  end
  
  # given the id of the item to duplicate create a copy and return that copy
  def self.duplicate_item(item_id, conference_id = nil, keep_room_assignment = true, dict = {}) #, dest_conference = nil)
    old_item = ProgrammeItem.find item_id
    
    kopy = old_item.deep_clone include: ProgrammeItem.deep_clone_members(keep_room_assignment, !conference_id), 
      dictionary: dict do |original, _kopy|
        _kopy.title = _kopy.title + " (copy)" if _kopy.respond_to?(:title) && !conference_id
        _kopy.pub_reference_number = nil if _kopy.respond_to?(:pub_reference_number)
        _kopy.conference_id = conference_id if _kopy.respond_to?(:conference_id) && conference_id
      end

    if !kopy.format
      kopy.format_id = nil
    end
    
    kopy.save!
    kopy
  end
  
  def self.findAllItems
    time_slots = Arel::Table.new(:time_slots)
    parent_time_slots = time_slots.alias("parent_time_slots")
    
    ProgrammeItem.select([ ProgrammeItem.arel_table[Arel.star],
                          parent_time_slots[:start].as('parent_item_start')
                        ]).
                        includes([:time_slot, :room_item_assignment, :programme_item_assignments, {:people => :pseudonym}, {:room => [:venue]}]).
                        joins(find_all_joins).
                        order(
                          %w(
                            IF(parent_item_start IS NULL, time_slots.start, parent_item_start) ASC,
                            programme_items.title
                          ).join(" ")
                        )
    
  end
  
  def self.find_all_joins
    programme_items = Arel::Table.new(:programme_items)
    parent_items = programme_items.alias('parent_items')
    room_item_assignments = Arel::Table.new(:room_item_assignments)
    parent_room_item_assignments = room_item_assignments.alias('parent_room_item_assignments')
    time_slots =  Arel::Table.new(:time_slots)
    parent_time_slots = time_slots.alias("parent_time_slots")
    
    [
        programme_items.
          create_join(room_item_assignments, 
            programme_items.create_on(
              room_item_assignments[:programme_item_id].eq(programme_items[:id])
            ),
            Arel::Nodes::OuterJoin),
        programme_items.
          create_join(time_slots, 
            programme_items.create_on(
              room_item_assignments[:time_slot_id].eq(time_slots[:id])
            ),
            Arel::Nodes::OuterJoin),
        programme_items.
          create_join(parent_items, 
            programme_items.create_on(
              parent_items[:id].eq(programme_items[:parent_id])
            ),
            Arel::Nodes::OuterJoin),
        programme_items.
          create_join(parent_room_item_assignments, 
            parent_room_item_assignments.create_on(
              parent_room_item_assignments[:programme_item_id].eq(parent_items[:id])
            ),
            Arel::Nodes::OuterJoin),
        programme_items.
          create_join(parent_time_slots, 
            parent_time_slots.create_on(
              parent_room_item_assignments[:time_slot_id].eq(parent_time_slots[:id])
            ),
            Arel::Nodes::OuterJoin)
    ]
  end

  
  def self.assign_reference_numbers(increment = 3)
      items = ProgrammeItem.
                  references([:time_slot, :room_item_assignment, {:people => :pseudonym}, {:room => [:venue]} ]).
                  where(visibility_id: Visibility['None'].id).
                  includes([:time_slot, :room_item_assignment, {:people => :pseudonym}, {:room => [:venue]} ]).
                  order('time_slots.start ASC, venues.sort_order, rooms.sort_order')
      
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
  def self.countItems(filters = nil, extraClause = nil, nameSearch=nil, context=nil, tags = nil, theme_ids = nil, ignoreScheduled = false, include_children = true, page_to = nil, index=nil, sort_order='asc')
    clause = where_clause(nameSearch, filters, extraClause, theme_ids, ignoreScheduled, include_children, page_to)
    tagquery = DataService.genTagSql(context, tags)
    
    if (index != nil && index != "")
      order_clause = index + " " + sort_order
    else
      order_clause = "time_slots.start asc, programme_items.title asc"
    end

    if tagquery.empty?
      ProgrammeItem.where(clause).joins(join_clause).order(order_clause).uniq.count
    else
      ProgrammeItem.where(clause).joins(join_clause).tagged_with(*tagquery).order(order_clause).uniq.count
    end
  end
  
  def self.findItems(rows=15, page=1, index=nil, sort_order='asc', filters = nil, extraClause = nil, nameSearch=nil, 
                        context=nil, tags = nil, theme_ids = nil, ignoreScheduled = false, include_children = true, page_to = nil)
    clause = where_clause(nameSearch, filters, extraClause, theme_ids, ignoreScheduled, include_children, page_to)
    tagquery = DataService.genTagSql(context, tags)
    
    offset = (page - 1) * rows.to_i
    offset = 0 if offset < 0
    
    if (index != nil && index != "")
      order_clause = index + " " + sort_order
    else
      order_clause = "time_slots.start asc, programme_items.title asc"
    end

    if tagquery.empty?
      items = ProgrammeItem.includes(:children).
                      where(clause).joins(join_clause).
                      order(order_clause).
                      offset(offset).
                      limit(rows).
                      uniq.includes(:programme_item_assignments)
    else
      items = ProgrammeItem.includes(:children).tagged_with(*tagquery).
                      where(clause).joins(join_clause).
                      order(order_clause).
                      offset(offset).
                      limit(rows).
                      uniq.includes(:programme_item_assignments)
    end
  end
  
  #
  #
  #
  def self.findProgramItemsForPerson(person)
    ProgrammeItemAssignment.
        references(
          {:programmeItem => [{:programme_item_assignments => {:person => [:pseudonym, :email_addresses]}}, :equipment_types, {:room => :venue}, :time_slot]}
        ).
        where(
            ['(programme_item_assignments.person_id = ?) AND (programme_item_assignments.role_id in (?))', 
              person.id, 
              [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['OtherParticipant'].id,PersonItemRole['Invisible'].id]]        
        ).
        includes(
          {:programmeItem => [{:programme_item_assignments => {:person => [:pseudonym, :email_addresses]}}, :equipment_types, {:room => :venue}, :time_slot]}
        ).
        order("time_slots.start asc")
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
    query = "select count(*) as count from (" + itemConflictSqlWithParent(day) + ") res"
    res = ActiveRecord::Base.connection.select_one(query)
    count = res['count'].to_i

    query = "select count(*) as count from (" + itemConflictSql(day) + ") res"
    res = ActiveRecord::Base.connection.select_one(query)
    count += res['count'].to_i

    query = "select count(*) as count from (" + sub_item_conflict_sql(day) + ") res"
    res = ActiveRecord::Base.connection.select_one(query)
    count += res['count'].to_i
    
    count
  end
  
  def self.getItemConflicts(day = nil)
    query = itemConflictSql(day)

    res = ActiveRecord::Base.connection.select_all(query)

    query = itemConflictSqlWithParent(day)

    res.to_a.concat(ActiveRecord::Base.connection.select_all(query).to_a) # Combine the queries

    query = sub_item_conflict_sql(day)

    res.to_a.concat(ActiveRecord::Base.connection.select_all(query).to_a) # Combine the queries
  end
  
  #
  #
  #
  def self.getNbrRoomConflicts(day = nil)
    query = "select count(*) as count from (" + roomConflictsSql(day) + ") res"
    
    res = ActiveRecord::Base.connection.select_one(query)
    
    res['count'].to_i
  end
  
  def self.getRoomConflicts(day = nil)
    ActiveRecord::Base.connection.select_all(roomConflictsSql(day))
  end
  
  #
  #
  #
  def self.getNbrExcludedItemConflicts(day = nil)
    query = "select count(*) as count from (" + excludedItemConflictsSql(day) + ") res"
    res = ActiveRecord::Base.connection.select_one(query)
    count = res['count'].to_i

    query = "select count(*) as count from (" + excludedItemConflictsSqlWithParent(day) + ") res"
    res = ActiveRecord::Base.connection.select_one(query)
    count += res['count'].to_i
    
    count
  end
  
  def self.getExcludedItemConflicts(day = nil)
    res = ActiveRecord::Base.connection.select_all(excludedItemConflictsSql(day))
    
    res.to_a.concat(ActiveRecord::Base.connection.select_all(excludedItemConflictsSqlWithParent(day)).to_a) # Combine the queries
  end
  
  #
  #
  #
  def self.getNbrExcludedTimeConflicts(day = nil)
    query = "select count(*) as count from (" + excludedTimeConflictsSql(day) + ") res"
    res = ActiveRecord::Base.connection.select_one(query)
    count = res['count'].to_i
    
    query = "select count(*) as count from (" + excludedTimeConflictsSqlWithParent(day) + ") res"
    res = ActiveRecord::Base.connection.select_one(query)
    count += res['count'].to_i
    
    count
  end
  
  def self.getExcludedTimeConflicts(day = nil)
    res = ActiveRecord::Base.connection.select_all(excludedTimeConflictsSql(day))

    res.to_a.concat(ActiveRecord::Base.connection.select_all(excludedTimeConflictsSqlWithParent(day)).to_a) # Combine the queries
  end
  
  #
  #
  #
  def self.getNbrAvailabilityConficts(day = nil)
    query = "select count(*) as count from (" + availabilityConfictsSql(day) + ") res"
    res = ActiveRecord::Base.connection.select_one(query)
    count = res['count'].to_i

    query = "select count(*) as count from (" + availabilityConfictsSqlWithParent(day) + ") res"
    res = ActiveRecord::Base.connection.select_one(query)
    count += res['count'].to_i
    
    count
  end
  
  def self.getAvailabilityConficts(day = nil)
    res = ActiveRecord::Base.connection.select_all(availabilityConfictsSql(day))

    res.to_a.concat(ActiveRecord::Base.connection.select_all(availabilityConfictsSqlWithParent(day)).to_a) # Combine the queries
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

  def self.where_clause(nameSearch, filters, extraClause, theme_ids, ignoreScheduled, include_children, page_to = nil)
    clause = DataService.createWhereClause(filters, 
                  ['programme_items.format_id','programme_items.pub_reference_number'],
                  ['programme_items.format_id','programme_items.pub_reference_number'], ['programme_items.title'])

    if ignoreScheduled
      clause = DataService.addClause( clause, 'room_item_assignments.programme_item_id is null', nil )
    end

    # add the name search of the title
    if nameSearch
      st = DataService.getFilterData( filters, 'programme_items.title' )
      if (st)
        clause = DataService.addClause(clause,'programme_items.title like ? ','%' + st + '%')
        clause = DataService.addClause(clause,'children.title like ? ','%' + st + '%','OR') if include_children
      end
    end
    if theme_ids && theme_ids.size > 0
      clause = DataService.addClause(clause,'themes.theme_name_id in (?) ',theme_ids) 
      clause = DataService.addClause(clause,'child_themes.theme_name_id in (?) ',theme_ids, 'OR') if include_children
    end
    
    # TODO - add these
    # if ignorePending
      # clause = addClause( clause, 'pending_publication_items.programme_item_id is null', nil )
      # clause = addClause( clause, "programme_items.visibility_id != #{Visibility['None'].id}", nil )
    # end
    
    # TODO - assumed that the new creation does not have a time slot. Need to change
    clause = DataService.addClause( clause, 'programme_items.title <= ? AND time_slots.start is null', page_to) if page_to
    clause = DataService.addClause( clause, 'programme_items.parent_id is null', nil) # do not show the children in the result set

    clause    
  end

  def self.join_clause()
    'LEFT JOIN room_item_assignments ON room_item_assignments.programme_item_id = programme_items.id ' +
    'LEFT JOIN time_slots on time_slots.id = room_item_assignments.time_slot_id ' +
    'LEFT OUTER JOIN programme_items as children on children.parent_id = programme_items.id ' +
    "LEFT OUTER JOIN themes on themes.themed_id = programme_items.id AND themes.themed_type = 'ProgrammeItem' " +
    "LEFT OUTER JOIN themes as child_themes on child_themes.themed_id = children.id AND child_themes.themed_type = 'ProgrammeItem' " +
    "LEFT OUTER JOIN rooms on rooms.id = room_item_assignments.room_id"    
  end

  # For double book participants
  # take into account parent items
  # todo - prune out parent of the item i.e. so it is not a conflict with itself....
  def self.itemConflictSqlWithParent(day = nil)
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
    
    candidate_items = items.alias('candidate_items')
    parents = items.alias('parent_items')

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
# join assigment ot item and item to parent
                                      join(candidate_items).on(candidate_items[:id].eq(assignments[:programme_item_id])).
                                      join(parents).on(parents[:id].eq(candidate_items[:parent_id])).
                                      join(room_assignments).on(room_assignments[:programme_item_id].eq(parents[:id])).
                                      join(time_slots).on(room_assignments[:time_slot_id].eq(time_slots[:id])).
                                      join(assignments_alias).on(assignments[:id].not_eq(assignments_alias[:id])).
                                      join(room_assignments_alias).on(room_assignments_alias[:programme_item_id].eq(assignments_alias[:programme_item_id])).
                                      join(time_slots_alias).on(room_assignments_alias[:time_slot_id].eq(time_slots_alias[:id])).
                                      where(
                                          time_slots[:end].gt(time_slots_alias[:start]).
                                          and(time_slots[:start].lteq(time_slots_alias[:start])).
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

    query = query.where(self.constraints()) if self.constraints()
    
    query.to_sql
  end
  
  #
  # Need sub-item conflicts
  #
  def self.sub_item_conflict_sql(day = nil)
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
    
    candidate_items = items.alias('candidate_items')
    parents = items.alias('parent_items')
    parents_alias = items.alias('parent_items_2')

    pitems_alias = items.alias('pitems_2')

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
# join assigment to item and item to parent
                                      join(candidate_items).on(candidate_items[:id].eq(assignments[:programme_item_id])).
                                      join(parents).on(parents[:id].eq(candidate_items[:parent_id])).
                                      join(room_assignments).on(room_assignments[:programme_item_id].eq(parents[:id])).
                                      join(time_slots).on(room_assignments[:time_slot_id].eq(time_slots[:id])).
                                      join(assignments_alias).on(assignments[:id].not_eq(assignments_alias[:id])).
# need the parent of the other assignment ... items_alias
                                      join(pitems_alias).on(pitems_alias[:id].eq(assignments_alias[:programme_item_id])).
                                      join(parents_alias).on(parents_alias[:id].eq(pitems_alias[:parent_id])).

                                      join(room_assignments_alias).on(room_assignments_alias[:programme_item_id].eq(parents_alias[:id])).
                                      join(time_slots_alias).on(room_assignments_alias[:time_slot_id].eq(time_slots_alias[:id])).
                                      where(
                                          time_slots[:end].gt(time_slots_alias[:start]).
                                          and(time_slots[:start].lteq(time_slots_alias[:start])).
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

    query = query.where(self.constraints()) if self.constraints()
    
    query.to_sql    
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
                                      join(assignments_alias).on(assignments[:id].not_eq(assignments_alias[:id])).
                                      join(room_assignments_alias).on(room_assignments_alias[:programme_item_id].eq(assignments_alias[:programme_item_id])).
                                      join(time_slots_alias).on(room_assignments_alias[:time_slot_id].eq(time_slots_alias[:id])).
                                      where(
                                          time_slots[:end].gt(time_slots_alias[:start]).
                                          and(time_slots[:start].lteq(time_slots_alias[:start])).
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

    query = query.where(self.constraints()) if self.constraints()
    
    query.to_sql
  end

  #
  #
  #
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
                  on(conflict_exceptions[:affected].eq(room_assignments[:room_id]).
                      and(conflict_exceptions[:src1].eq(room_assignments[:programme_item_id])).
                      and(conflict_exceptions[:src2].eq(room_assignments_alias[:programme_item_id]))
                    ).where(
                      conflict_exceptions[:id].eq(nil)
                    )

    query = query.join(rooms).on(rooms[:id].eq(room_assignments[:room_id])).
                  join(items).on(items[:id].eq(room_assignments[:programme_item_id])).
                  join(rooms_alias).on(rooms_alias[:id].eq(room_assignments_alias[:room_id])).
                  join(items_alias).on(items_alias[:id].eq(room_assignments_alias[:programme_item_id]))

    query = query.where(self.constraints()) if self.constraints() #.take(1000) # TODO - we need paging in the results

    query.take(1000).to_sql
  end

  
  def self.excludedItemConflictsSqlWithParent(day = nil)
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

    candidate_items = items.alias('candidate_items')
    parents = items.alias('parent_items')

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
                          join(parents).on(parents[:id].eq(programme_items_alias[:parent_id])).
                          join(room_assignments_alias).on(room_assignments_alias[:programme_item_id].eq(parents[:id])).
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

    query = query.where(self.constraints()) if self.constraints()

    query.to_sql
  end

  #
  #
  #
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

    query = query.where(self.constraints()) if self.constraints()

    query.to_sql
  end

  #
  #
  #
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
    
    query = query.where(self.constraints()) if self.constraints()

    query.to_sql
  end

  def self.excludedTimeConflictsSqlWithParent(day = nil)
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

    candidate_items = programme_items.alias('candidate_items')
    parents = programme_items.alias('parent_items')

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

                          join(parents).on(parents[:id].eq(room_assignments[:programme_item_id])).
                          join(candidate_items).on(candidate_items[:parent_id].eq(parents[:id])).
                          join(assignments).on(
                              assignments[:programme_item_id].eq(candidate_items[:id]).and(
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
    
    query = query.where(self.constraints()) if self.constraints()

    query.to_sql
  end

  #
  #
  #
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
    
    query = query.where(self.constraints()) if self.constraints()

    query.to_sql
  end

  def self.availabilityConfictsSqlWithParent(day = nil)
    conflict_exceptions = Arel::Table.new(:conflict_exceptions)
    
    people = Arel::Table.new(:people)
    
    available_dates = Arel::Table.new(:available_dates)

    assignments = Arel::Table.new(:programme_item_assignments)
    room_assignments = Arel::Table.new(:room_item_assignments)
    time_slots = Arel::Table.new(:time_slots)

    rooms = Arel::Table.new(:rooms)
    people = Arel::Table.new(:people)
    programme_items = Arel::Table.new(:programme_items)

    candidate_items = programme_items.alias('candidate_items')
    children = programme_items.alias('children_items')

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

                          join(children).on(children[:id].eq(assignments[:programme_item_id])).
                          join(programme_items).on(programme_items[:id].eq(children[:parent_id])).
                          join(room_assignments).on(room_assignments[:programme_item_id].eq(programme_items[:id])).
                          join(rooms).on(rooms[:id].eq(room_assignments[:room_id])).
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
    
    query = query.where(self.constraints()) if self.constraints()

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

    children = programme_items.alias('children')
    child_assignments = assignments.alias('child_assignments')
    children_alias = programme_items.alias('children_alias')
    child_assignments_alias = assignments.alias('child_assignments_alias')

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
                          join(children, Arel::Nodes::OuterJoin).on(children[:parent_id].eq(room_assignments[:programme_item_id])).
                          join(child_assignments, Arel::Nodes::OuterJoin).on(children[:id].not_eq(nil).and(child_assignments[:programme_item_id].eq(children[:id]))).

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

                          join(children_alias, Arel::Nodes::OuterJoin).on(children_alias[:parent_id].eq(programme_items_alias[:id])).
                          join(child_assignments_alias, Arel::Nodes::OuterJoin).on(children_alias[:id].not_eq(nil).and(child_assignments_alias[:programme_item_id].eq(children_alias[:id]))).

                          where(
                            time_slots[:end].eq(time_slots_alias[:start]).
                            and( assignments[:id].not_eq(assignments_alias[:id]) ).
                            and( 
                              assignments[:person_id].eq(assignments_alias[:person_id]).
                              or(child_assignments[:person_id].eq(child_assignments_alias[:person_id])).
                              or(assignments[:person_id].eq(child_assignments_alias[:person_id])).
                              or(child_assignments[:person_id].eq(assignments_alias[:person_id]))
                            )
                          )

    query = query.where(room_assignments[:day].eq(day.to_s).and(room_assignments_alias[:day].eq(day.to_s))) if day

    query = query.join(conflict_exceptions, Arel::Nodes::OuterJoin).
                                                  on(conflict_exceptions[:affected].eq(people[:id]).
                                                      and(conflict_exceptions[:src1].eq(assignments[:programme_item_id])).
                                                      and(conflict_exceptions[:src2].eq(assignments_alias[:programme_item_id]))
                                                    ).where(
                                                      conflict_exceptions[:id].eq(nil)
                                                    ).order(people[:id])
    
    query = query.where(self.constraints()) if self.constraints()

    query.to_sql
  end

  def self.constraints(*args)
    nil
  end

end
