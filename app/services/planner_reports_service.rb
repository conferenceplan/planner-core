#
#
#
module PlannerReportsService
  
  # Search the programme items and report back on the sizes
  def self.word_counts(title_size = 0, short_title_size = 0, precis_size = 0, short_precis_size = 0)
    programme_items = Arel::Table.new(:programme_items)
    
    attrs = [
      programme_items[:id],
      programme_items[:title].as('title'),
      programme_items[:short_title].as('short_title'),
      programme_items[:precis].as('precis'),
      programme_items[:short_precis].as('short_precis'),
      word_counts_if_clause(programme_items[:title]).as('title_words'),
      word_counts_if_clause(programme_items[:short_title]).as('short_title_words'),
      word_counts_if_clause(programme_items[:precis]).as('precis_words'),
      word_counts_if_clause(programme_items[:short_precis]).as('short_precis_words')
    ]
    
    query = programme_items.project(*attrs).
                where(
                  word_counts_if_clause(programme_items[:title]).gt(title_size).or(
                    word_counts_if_clause(programme_items[:short_title]).gt(short_title_size)
                  ).or(
                    word_counts_if_clause(programme_items[:precis]).gt(precis_size)
                  ).or(
                    word_counts_if_clause(programme_items[:short_precis]).gt(short_precis_size)
                  )
                ).where(self.arel_constraints())

    ActiveRecord::Base.connection.select_all(query.to_sql)
  end
  
  #
  def self.items_over_capacity
    ProgrammeItem.where("(audience_size is not null) AND (audience_size > room_setups.capacity)").
                    includes([{:room_item_assignment => {:room => [:room_setup, :venue]}}, :time_slot]).
                    where(self.constraints()).
                    order("time_slots.start, venues.sort_order, rooms.sort_order")
  end
  
  #
  # Find people participating in the programme that do not have a bio
  #
  def self.findParticipantsWithNoBios
    # Person must be assigned to a programme item (and be visible to the members)
    conditions = ["(programme_item_assignments.role_id in (?)) AND (programme_items.print = true) AND (edited_bios.id is null OR edited_bios.bio is null OR edited_bios.bio = '')",
                     [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id] ]

    Person.where(conditions).
            includes([:pseudonym, {:programmeItemAssignments => :programmeItem}]).
            joins("left outer join edited_bios on edited_bios.person_id = people.id").
            where(self.constraints()).
            order("people.last_name")
  end

  #
  #
  #
  def self.findEditedBios( acceptanceStatus = AcceptanceStatus['Accepted'], inviteStatus = InviteStatus['Invited'], since = nil )
    cndStr = ''
    cndStr += '(person_con_states.acceptance_status_id = ?)' if acceptanceStatus
    cndStr += ' AND ' if !cndStr.empty? && inviteStatus
    cndStr += '(person_con_states.invitestatus_id = ?)' if inviteStatus
    cndStr += ' AND ' if !cndStr.empty? && since
    cndStr += '(edited_bios.updated_at > ?)' if since

    conditions = [cndStr]
    conditions << acceptanceStatus.id if acceptanceStatus
    conditions << inviteStatus.id if inviteStatus
    conditions << since if since

    EditedBio.where(conditions).
              joins({:person => :person_con_state}).
              includes({:person => :pseudonym}).
              where(self.constraints()).
              order('people.last_name, people.first_name')
  end

  def self.findEmptyPanels
    
    ProgrammeItem.joins('left outer JOIN programme_item_assignments ON programme_item_assignments.programme_item_id = programme_items.id').
                  includes(:time_slot).
                  where("programme_item_assignments.id is null").
                  where(self.constraints()).
                  order("time_slots.start")

  end
  
  def self.findPanelsWithEquipmentNeeds(plus_setups = true)
    conditions = []

    if plus_setups
      setup = Format.find_by_name('RESET') # TODO - check that this makes sense i.e. format of name RESET?
      cond_str = "(equipment_needs.programme_item_id is not NULL or formats.id = ?) and (time_slots.start is not NULL || time_slots_programme_items.start is not null)"
      conditions.push setup
    else
      cond_str = "equipment_needs.programme_item_id is not NULL and (time_slots.start is not NULL || time_slots_programme_items.start is not null)"
    end
    
    conditions.unshift cond_str
    
    ProgrammeItem.where(conditions).
                  includes([
                          { :programme_item_assignments => { :person => :pseudonym} },
                          { :parent => [:time_slot, {:room => :venue}, :format] },
                          :time_slot, 
                          {:room => :venue}, 
                          :format, 
                          :equipment_needs
                          ]).
                  order("time_slots.start, venues.sort_order, rooms.sort_order")
  end
  
  def self.findPanelsWithPanelists(sort_by = '', mod_date = '1900-01-01', format_id = nil, sched_only = false, equip_only = false, plus_setups = false)

    cond_str = "(programme_items.updated_at >= ? or programme_item_assignments.updated_at >= ? or (programme_items.updated_at is NULL and programme_items.created_at >= ?) or (programme_item_assignments.updated_at is NULL and programme_item_assignments.created_at >= ?))"
    cond_str << " and time_slots.start is not NULL" if sched_only
    cond_str << " and programme_item_assignments.role_id in (?)"

    conditions = [mod_date, mod_date, mod_date, mod_date, [PersonItemRole['Moderator'].id, PersonItemRole['Participant'].id]]

    if equip_only
      if plus_setups
        setup = Format.find_by_name('RESET') # TODO - check that this makes sense i.e. format of name RESET?
        cond_str << " and (equipment_needs.programme_item_id is not NULL or formats.id = ?)"
        conditions.push setup
      else
        cond_str << " and equipment_needs.programme_item_id is not NULL"
      end
    end
    
    if format_id
      cond_str << " and formats.id = ?"
      conditions.push format_id
    end
      
    conditions.unshift cond_str

    if sort_by == 'time'
      ord_str = "time_slots.start, time_slots.end, venues.sort_order, rooms.sort_order, people.last_name"
    elsif sort_by == 'room'
      ord_str = "venues.sort_order, rooms.sort_order, time_slots.start, time_slots.end, people.last_name"
    else
      ord_str = "programme_items.title, people.last_name"
    end
    
    ProgrammeItem.where(conditions).
                  includes([{:programme_item_assignments => {:person => :pseudonym}}, :time_slot, {:room => :venue}, :format, :equipment_needs]).
                  order(ord_str)
  end
  
  #
  #
  #
  def self.findPeopleWithoutItems
    Person.joins([:person_con_state]).
            joins("left outer join programme_item_assignments on programme_item_assignments.person_id = people.id").
            includes([:pseudonym]).
            where(["person_con_states.acceptance_status_id in (?) AND programme_item_assignments.person_id is null", 
                        [AcceptanceStatus['Accepted'].id, AcceptanceStatus['Probable'].id]]).
            where(self.constraints()).
            order('people.last_name')
  end
  
  #
  #
  #  
  def self.findPanelistsWithPanels(peopleIds = nil, additional_roles = nil, scheduledOnly = false, visibleOnly = false, format_id = nil)
    roles =  [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id] # ,PersonItemRole['Invisible'].id
    roles.concat(additional_roles) if additional_roles
    
    assignments = Arel::Table.new(ProgrammeItemAssignment.table_name)
    items = Arel::Table.new(ProgrammeItem.table_name)
    time_slots = Arel::Table.new(TimeSlot.table_name)
    parent_time_slots = time_slots.alias('time_slots_programme_items') # NOTE - this alias is what AR generates ....
    
    conditions = assignments[:role_id].in(roles)
    conditions = conditions.and(assignments[:person_id].in(peopleIds)) if peopleIds
    conditions = conditions.and(time_slots[:start].not_eq(nil).or(parent_time_slots[:start].not_eq(nil))) if scheduledOnly
    conditions = conditions.and(items[:print].eq(true)) if visibleOnly
    conditions = conditions.and(items[:format_id].eq(format_id)) if format_id
    
    Person.
          includes({:pseudonym => {}, :programmeItemAssignments => {
                      :programmeItem => [
                          :time_slot, 
                          {:room => :venue}, 
                          # :format, 
                          :parent => [:time_slot, {:room => :venue}, :format] ]
                    }
                  }).
          where(conditions).
          where(self.constraints()).
          order(Person.arel_table[:last_name].asc, parent_time_slots[:start].asc, time_slots[:start].asc)
  end

  #
  #
  #  
  def self.findPanelistsAndBios(order_by)
    roles =  [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id] # ,PersonItemRole['Invisible'].id
    cndStr = '(programme_item_assignments.role_id in (?))'
    cndStr += ' AND (time_slots.start is not NULL || time_slots_programme_items.start is not null)'
    cndStr += ' AND (programme_items.print = true)'

    conditions = [cndStr, roles]

    # TODO - add in parent here
    Person.where(conditions).
          includes([
                    :pseudonym, :edited_bio, :bio_image , 
                    :programmeItemAssignments => {
                      :programmeItem => [
                            { :parent => [:time_slot, {:room => :venue}, :format] },
                            { :room => :venue }, 
                            :time_slot, 
                            :format
                          ]
                      }
                  ]).
          where(self.constraints()).
          order(order_by)
  end
  
  #
  #
  #
  def self.findPublishedPanelistsWithPanels(peopleIds = nil, additional_roles = nil, itemIds = nil, formatList = nil)
    roles =  [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id]
    roles.concat(additional_roles) if additional_roles
    cndStr = '(published_programme_item_assignments.role_id in (?))'
    cndStr += ' AND (published_programme_item_assignments.person_id in (?))' if peopleIds
    cndStr += ' AND (published_programme_item_assignments.published_programme_item_id in(?))' if itemIds
    cndStr += " AND published_programme_items.format_id in(?)" if formatList

    conditions = [cndStr, roles] #, [AcceptanceStatus['Accepted'].id, AcceptanceStatus['Probable'].id]]
    conditions << peopleIds if peopleIds
    conditions << itemIds if itemIds
    conditions << formatList if formatList
    
    Person.where(conditions).
              includes([
                    :pseudonym, 
                    {:published_programme_items => [
                      :format, 
                      {:published_room => :published_venue}, :published_time_slot,
                      {:parent => [:published_time_slot, {:published_room => :published_venue}, :format] }
                     ]}
                  ]).
              where(self.constraints()).
              order("people.last_name, published_time_slots.start asc")
  end
  
  #
  #
  #
  def self.findItemsWithNoTags
    ProgrammeItem.joins('LEFT JOIN taggings ON taggings.taggable_id = programme_items.id AND taggings.taggable_type = "ProgrammeItem"').where('taggings.id IS NULL')
  end
  
  #
  #
  #
  def self.findTagsByContext(context)
    if getTagOwner
      condition = ['context = ? and tagger_id = ?', context, getTagOwner]
    else
      condition = ['context = ?', context]
    end
    
    tags = ActsAsTaggableOn::Tagging.
                            where(condition).
                            joins("join tags on taggings.tag_id = tags.id").
                            where(self.constraints()).select('distinct name')
    
    tags.collect! {|t| t.name}
    peopleAndTags = Array.new
    tags.each do |tag|
        if getTagOwner
          peopleAndTags.concat Person.tagged_with(tag, :on => context, :owned_by => getTagOwner)
        else  
          peopleAndTags.concat Person.tagged_with(tag, :on => context)
        end
    end
    peopleAndTags.uniq!
    peopleAndTags.sort! {|x,y| x.last_name <=> y.last_name}
    peopleAndTags.each do |n|
      if getTagOwner
        n.details = n.owner_tags_on(getTagOwner, context).collect{|t| t.name}
      else  
        n.details = n.tag_list_on(context)
      end
    end
    
    peopleAndTags
  end
  
  #
  #
  #
  def self.findPeopleByTag(tags = nil)
    taggings = Arel::Table.new(:taggings)
    tags_table = Arel::Table.new(:tags)
    people = Arel::Table.new(:people)
    pseudonyms = Arel::Table.new(:pseudonyms)
    
    attrs = [
      taggings[:context].as('context'), tags_table[:name].as('tag'),
      people[:first_name].as('first_name'), people[:last_name].as('last_name'), people[:suffix].as('suffix'),
      pseudonyms[:first_name].as('pub_first_name'), pseudonyms[:last_name].as('pub_last_name'), pseudonyms[:suffix].as('pub_suffix'),
    ]
    
    query = tags_table.project(*attrs).
                  join(taggings).on(taggings[:tag_id].eq(tags_table[:id]).and(taggings[:taggable_type].eq('Person'))).
                  join(people).on(people[:id].eq(taggings[:taggable_id])).
                  join(pseudonyms, Arel::Nodes::OuterJoin).on(pseudonyms[:person_id].eq(people[:id])).
                  where(self.arel_constraints())

    query = query.where(tags_table[:name].in(tags.split(',').collect{|t| t.strip })) if !tags.blank? # TODO - redo to use wildcard
    
    query = query.order(taggings[:context], tags_table[:name], people[:last_name])
    
    res = ActiveRecord::Base.connection.select_all(query.to_sql)
    
    res.group_by {|b| [b['context'], b['tag']] }
  end

  #
  #
  #
  def self.findMaxParticipants
    prog_items = Arel::Table.new(:programme_item_assignments)

    query = prog_items.project((prog_items[:person_id].count).as('people')).
                where(prog_items[:role_id].in([PersonItemRole['Moderator'].id, PersonItemRole['Participant'].id])).
                where(self.arel_constraints()).
                group(prog_items[:programme_item_id])

    ActiveRecord::Base.connection.select_all( "select max(people) as max_people from (" + query.to_sql + ") as p" )
  end
  

  #
  #
  #
  def self.findPanelsByRoom
    
    Room.includes([
                    :venue,
                    {:programme_items => [
                        {:children => :equipment_needs},
                        :time_slot, 
                        :format, 
                        :equipment_needs
                        ]}
                  ]).
          where("time_slots.start is not NULL").
          where(self.constraints()).
          order("venues.sort_order, rooms.sort_order, time_slots.start, time_slots.end")
  end
  
  #
  #
  #
  def self.findPublishedPanelsByRoom(roomIds = nil, day = nil)
    cndStr = " published_time_slots.start is not NULL"
    cndStr += ' AND (published_rooms.id in (?))' if roomIds
    cndStr += ' AND (published_room_item_assignments.day = ?)' if day

    conditions = [cndStr]
    conditions << roomIds if roomIds
    conditions << day if day
    
    PublishedRoom.where(conditions).
            includes([:published_venue,
              :published_room_item_assignments => 
              [
                :published_time_slot, 
                {:published_programme_item => #
                  [
                    {:published_programme_item_assignments => {:person => :pseudonym}}, 
                    :format,
                    {:children => {:published_programme_item_assignments => {:person => :pseudonym}}}
                  ]
                }
              ]
            ]).
            where(self.constraints()).
            order("published_venues.sort_order, published_rooms.sort_order, published_time_slots.start")
    
  end
  
  #
  #
  #
  def self.findPanelsByTimeslot
    TimeSlot.joins([{:rooms => :venue}]).
            includes([
                {:rooms => :venue}, 
                {:programme_items => [
                  :equipment_needs,
                  {:children => :equipment_needs},
                ]}
              ]).
            where("time_slots.start is not NULL").
            where(self.constraints()).
            order("time_slots.start, venues.sort_order, rooms.sort_order")
  end
  
  #
  #
  #
  def self.findProgramItemsByTimeAndRoom
    TimeSlot.joins([:programme_items]).
              includes([
                  {:rooms => :venue},
                  {:programme_items => 
                    [
                      {:programme_item_assignments => {:person => :pseudonym}},
                      {:children => {:programme_item_assignments => {:person => :pseudonym}}},
                      :format
                    ]
                  }
                 ]).
              where("programme_items.print = 1 and time_slots.start is not NULL").
              where(self.constraints()).
              order("time_slots.start, venues.sort_order, rooms.sort_order") #
  end

  #
  #
  #
  def self.findPersonAndItemConstraints
    
    ProgrammeItemAssignment.select("people.last_name, programme_item_assignments.person_id, IF(room_item_assignments.day is not null, room_item_assignments.day, parent_rooms.day) day, count(programme_item_assignments.person_id) as nbr_items, person_constraints.max_items_per_day, person_constraints.max_items_per_con").
        joins("left outer join room_item_assignments on room_item_assignments.programme_item_id = programme_item_assignments.programme_item_id").
        joins("left join person_constraints on person_constraints.person_id = programme_item_assignments.person_id").
        joins("left join programme_items on programme_items.id = programme_item_assignments.programme_item_id").
        joins("left join programme_items as parents on parents.id = programme_items.parent_id").
        joins("left join room_item_assignments as parent_rooms ON parent_rooms.programme_item_id = parents.id").
        joins(:person).
        includes({:person => [:pseudonym, {:programmeItems => :time_slot}]}).
        where(self.constraints()).
        where("programme_item_assignments.person_id is not null AND programme_item_assignments.role_id in (" + PersonItemRole['Moderator'].id.to_s + "," + PersonItemRole['Participant'].id.to_s + ")").
        group("programme_item_assignments.person_id , IF(room_item_assignments.day is not null, room_item_assignments.day, parent_rooms.day)").
        order("people.last_name , people.first_name , IF(room_item_assignments.day is not null, room_item_assignments.day, parent_rooms.day)")
  end
  
  #
  #
  #
  def self.findPeopleOverMaxItems
    
    ProgrammeItemAssignment.select("people.last_name, programme_item_assignments.person_id, count(programme_item_assignments.person_id) as nbr_items, person_constraints.max_items_per_day, person_constraints.max_items_per_con").
            joins("right join room_item_assignments on room_item_assignments.programme_item_id = programme_item_assignments.programme_item_id").
            joins("left join person_constraints on person_constraints.person_id = programme_item_assignments.person_id").
            joins(:person).
            includes({:person => [:pseudonym, {:programmeItems => :time_slot}]}).
            where(self.constraints()).
            where("max_items_per_con > 0 AND programme_item_assignments.person_id is not null AND programme_item_assignments.role_id in (" + PersonItemRole['Moderator'].id.to_s + "," + PersonItemRole['Participant'].id.to_s + ")").
            group("programme_item_assignments.person_id").having("nbr_items > max_items_per_con").
            order("people.last_name, people.first_name")
        
  end
  
  #
  #
  #
  def self.findItemsWithOneParticipant
#{ :parent => [:time_slot, {:room => :venue}, :format] }
    
    ProgrammeItemAssignment.where("programme_item_assignments.person_id is not null AND programme_item_assignments.role_id in (" + PersonItemRole['Moderator'].id.to_s + "," + PersonItemRole['Participant'].id.to_s + ")").
            includes([
                {:person => :pseudonym}, 
                {
                  :programmeItem => {
                    :people => :programmeItems
                  }
                }
              ]).
            group("programme_item_assignments.programme_item_id").having("count(programme_item_assignments.programme_item_id) = 1").
            sort!{|a,b| a.person.last_name <=> b.person.last_name }
    
  end

  #
  #
  #
  def self.findPanelsWithoutModerators

    ids = ProgrammeItemAssignment.where("programme_item_assignments.person_id is not null AND programme_item_assignments.role_id in (" + PersonItemRole['Moderator'].id.to_s  + ")").
            group("programme_item_assignments.programme_item_id").
            having("count(programme_item_assignments.programme_item_id) >= 1").
            pluck(:programme_item_id)

    ProgrammeItem.all :include => [
          { :parent => [:time_slot, {:room => :venue}, :format] },
          :programme_item_assignments,
          :time_slot, 
          {:room => :venue}, 
          :format
        ],
      :conditions => ["(time_slots.start is not NULL || time_slots_programme_items.start is not null) AND (programme_items.minimum_people > 1 OR programme_items.maximum_people > 1) AND (programme_items.id not in (?))", ids],
      :order => "IF(time_slots.start is not null, time_slots.start, time_slots_programme_items.start), IF(time_slots.start is not null, time_slots.end, time_slots_programme_items.end), IF(venues.sort_order, venues.sort_order, venues_rooms.sort_order), IF(rooms.sort_order, rooms.sort_order, rooms_programme_items.sort_order)"
  end

#
#
#
protected

  def getTagOwner
    nil
  end

  def self.word_counts_if_clause(attr)
    attr_length = Arel::Nodes::NamedFunction.new( "CHAR_LENGTH", [ attr ])
    attr_replace = Arel::Nodes::NamedFunction.new( "REPLACE", [ attr, ' ', '' ])
    Arel::Nodes::NamedFunction.new("IF", [
                        attr_length.gt(0), 
                        (Arel::Nodes::Addition.new( Arel::Nodes::Subtraction.new(attr_length, Arel::Nodes::NamedFunction.new( "LENGTH", [ attr_replace ])), 1)),
                        0
                        ])
  end

  def self.constraints(*args)
    true
  end
  
  def self.arel_constraints(*args)
    true
  end
  
end
