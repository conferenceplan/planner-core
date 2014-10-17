#
#
#
module PlannerReportsService
  
  # Search the programme items and report back on the sizes
  def self.word_counts(title_size = 0, short_title_size = 0, precis_size = 0, short_precis_size = 0)
    ActiveRecord::Base.connection.select_all( ITEM_WORDS_SQL % [title_size,short_title_size,precis_size,short_precis_size] )
  end
  
  #
  def self.items_over_capacity
    ProgrammeItem.all :include => [{:room_item_assignment => {:room => [:room_setup, :venue]}}, :time_slot],
                      :conditions => "(audience_size is not null) AND (audience_size > room_setups.capacity)",
                      :order => "time_slots.start, venues.name desc, rooms.name"
  end
  
  #
  # Find people participating in the programme that do not have a bio
  #
  def self.findParticipantsWithNoBios
    # Person must be assigned to a programme item (and be visible to the members)
    conditions = ["(programme_item_assignments.role_id in (?)) AND (programme_items.print = true) AND (edited_bios.id is null OR edited_bios.bio is null OR edited_bios.bio = '')",
                     [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id] ]
    
    Person.all( :conditions => conditions,
              :include => [:pseudonym, {:programmeItemAssignments => :programmeItem}],
              :joins => "left outer join edited_bios on edited_bios.person_id = people.id",
              :order => "people.last_name")
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

    EditedBio.find :all, :include => {:person => :pseudonym},
                    :joins => {:person => :person_con_state},
                    :conditions => conditions,
                    :order => 'people.last_name, people.first_name'
  end

  def self.findEmptyPanels
    
    ProgrammeItem.joins('left outer JOIN programme_item_assignments ON programme_item_assignments.programme_item_id = programme_items.id').
                  includes(:time_slot).
                  where("programme_item_assignments.id is null").
                  order("time_slots.start")

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
      ord_str = "time_slots.start, time_slots.end, venues.name desc, rooms.name, people.last_name"
    elsif sort_by == 'room'
      ord_str = "venues.name desc, rooms.name, time_slots.start, time_slots.end, people.last_name"
    else
      ord_str = "programme_items.title, people.last_name"
    end
    
    ProgrammeItem.all :include => [{:programme_item_assignments => {:person => :pseudonym}}, :time_slot, {:room => :venue}, :format, :equipment_needs],
                      :conditions => conditions,
                      :order => ord_str

  end
  
  #
  #
  #
  def self.findPeopleWithoutItems
    Person.all :conditions => ["person_con_states.acceptance_status_id in (?) AND people.id not in (select person_id from programme_item_assignments)", [AcceptanceStatus['Accepted'].id, AcceptanceStatus['Probable'].id]], 
              :joins => :person_con_state,
              :include => :pseudonym,
              :order => "people.last_name"
  end
  
  #
  #
  #  
  def self.findPanelistsWithPanels(peopleIds = nil, additional_roles = nil, scheduledOnly = false, visibleOnly = false)
    roles =  [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id] # ,PersonItemRole['Invisible'].id
    roles.concat(additional_roles) if additional_roles
    cndStr = '(programme_item_assignments.role_id in (?))'
    cndStr += ' AND (programme_item_assignments.person_id in (?))' if peopleIds
    cndStr += ' AND (time_slots.start is not NULL)' if scheduledOnly
    cndStr += ' AND (programme_items.print = true)' if visibleOnly

    conditions = [cndStr, roles]
    conditions << peopleIds if peopleIds
    
    Person.all( :conditions => conditions, 
              :include => {:pseudonym => {}, :programmeItemAssignments => {:programmeItem => [:time_slot, {:room => :venue}, :format]}},
              :order => "people.last_name, time_slots.start asc")

  end
  # find people with items that have only one person...?
#    Person.all( :conditions => conditions, :include => {:pseudonym => {}, :programmeItemAssignments => {:programmeItem => [:time_slot, {:room => :venue}, :format]}},:order => "people.last_name, time_slots.start asc")
# Need a find panelists with panels that have only one person

  
  #
  #
  #
  def self.findPublishedPanelistsWithPanels(peopleIds = nil, additional_roles = nil, itemIds = nil)
    roles =  [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id]
    roles.concat(additional_roles) if additional_roles
    cndStr = '(published_programme_item_assignments.role_id in (?))'
    cndStr += ' AND (published_programme_item_assignments.person_id in (?))' if peopleIds
    # cndStr += ' AND (published_rooms.id in(?))' if roomIds
    cndStr += ' AND (published_programme_item_assignments.published_programme_item_id in(?))' if itemIds

    conditions = [cndStr, roles] #, [AcceptanceStatus['Accepted'].id, AcceptanceStatus['Probable'].id]]
    conditions << peopleIds if peopleIds
    # conditions << roomIds if roomIds
    conditions << itemIds if itemIds
    
    Person.all :conditions => conditions,
              :include => [:pseudonym, {:published_programme_items => [:format, {:published_room => :published_venue}, :published_time_slot]}],
              :order => "people.last_name, published_time_slots.start asc"
  end
  
  #
  #
  #
  def self.findTagsByContext(context)
    tags = ActsAsTaggableOn::Tagging.all(:conditions => ['context = ?', context], :joins => ["join tags on taggings.tag_id = tags.id"], :select => 'distinct(name)')
    tags.collect! {|t| t.name}
    peopleAndTags = Array.new
    tags.each do |tag|
      peopleAndTags.concat Person.tagged_with(tag, :on => context)
    end
    peopleAndTags.uniq!
    peopleAndTags.sort! {|x,y| x.last_name <=> y.last_name}
    peopleAndTags.each do |n|
      n.details = n.tag_list_on(context)
    end
    
    peopleAndTags
  end
  
  #
  #
  #
  def self.findPeopleByTag
  
    res = ActiveRecord::Base.connection.select_all(PEOPLE_TAG_QUERY)
    
    res1 = res.group_by {|b| [b['context'], b['tag']] }
    
    res1
  end
  
  #
  #
  #
  def self.findPanelsByRoom
    
    Room.all :include => [:venue, {:programme_items => [:time_slot, :format, :equipment_needs]}],
            :conditions => " time_slots.start is not NULL", 
            :order => "venues.name desc, rooms.name, time_slots.start, time_slots.end"
                        
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
    
    PublishedRoom.all :include => [:published_venue,
            :published_room_item_assignments => [:published_time_slot, {:published_programme_item => [{:published_programme_item_assignments => {:person => :pseudonym}}, :format]}] ], 
            :conditions => conditions, 
            :order => "published_venues.name desc, published_rooms.name, published_time_slots.start"

  end
  
  #
  #
  #
  def self.findPanelsByTimeslot

    TimeSlot.all :joins => [{:rooms => :venue}, {:programme_items => :format}], 
            :include => [{:rooms => :venue}, {:programme_items => :equipment_needs}], 
            :conditions => "time_slots.start is not NULL", 
            :order => "time_slots.start, time_slots.end, venues.name desc, rooms.name" 
    
  end
  
  #
  #
  #
  def self.findProgramItemsByTimeAndRoom( published = false )
    
    TimeSlot.all :joins => [{:rooms => :venue}, :programme_items], 
            :include => [{:rooms => :venue}, {:programme_items => [{:programme_item_assignments => {:person => :pseudonym}}, :format, ]}], 
            :conditions => "print = 1 and time_slots.start is not NULL",
            :order => "time_slots.start, time_slots.end, venues.name desc, rooms.name" 

    # Should be published items??? - TODO
  end
  
  #
  #
  #
  def self.findPersonAndItemConstraints
    
    ProgrammeItemAssignment.select("people.last_name, programme_item_assignments.person_id, room_item_assignments.day, count(programme_item_assignments.person_id) as nbr_items, person_constraints.max_items_per_day, person_constraints.max_items_per_con").
        joins("right join room_item_assignments on room_item_assignments.programme_item_id = programme_item_assignments.programme_item_id").
        joins("left join person_constraints on person_constraints.person_id = programme_item_assignments.person_id").
        joins(:person).
        includes({:person => [:pseudonym, {:programmeItems => :time_slot}]}).
        where("programme_item_assignments.person_id is not null AND programme_item_assignments.role_id in (" + PersonItemRole['Moderator'].id.to_s + "," + PersonItemRole['Participant'].id.to_s + ")").
        group("programme_item_assignments.person_id, room_item_assignments.day").
        order("people.last_name, people.first_name, room_item_assignments.day")

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
            where("programme_item_assignments.person_id is not null AND programme_item_assignments.role_id in (" + PersonItemRole['Moderator'].id.to_s + "," + PersonItemRole['Participant'].id.to_s + ")").
            group("programme_item_assignments.person_id").having("nbr_items > max_items_per_con").
            order("people.last_name, people.first_name")
        
  end
  
  #
  #
  #
  def self.findItemsWithOneParticipant
    
    ProgrammeItemAssignment.where("programme_item_assignments.person_id is not null AND programme_item_assignments.role_id in (" + PersonItemRole['Moderator'].id.to_s + "," + PersonItemRole['Participant'].id.to_s + ")").
            includes([{:person => :pseudonym}, {:programmeItem => {:people => :programmeItems}}]).
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

    ProgrammeItem.all :include => [:programme_item_assignments, :time_slot, {:room => :venue}, :format],
      :conditions => ["(time_slots.start is not NULL) AND (programme_items.minimum_people > 1 OR programme_items.maximum_people > 1) AND (programme_items.id not in (?))", ids],
      :order => "time_slots.start, time_slots.end, venues.name desc, rooms.name"

  end

#
#
#
protected

ITEM_WORDS_SQL = <<"EOS"
  SELECT programme_items.id, programme_items.title as title, programme_items.short_title as short_title, programme_items.precis as precis, programme_items.short_precis as short_precis,
  IF(LENGTH(title) > 0, (LENGTH(title) - LENGTH(REPLACE(title, ' ', ''))+1), 0) title_words,
  IF(LENGTH(short_title) > 0, (LENGTH(short_title) - LENGTH(REPLACE(short_title, ' ', ''))+1), 0) short_title_words,
  IF(LENGTH(precis) > 0, (LENGTH(precis) - LENGTH(REPLACE(precis, ' ', ''))+1), 0) precis_words,
  IF(LENGTH(short_precis) > 0, (LENGTH(short_precis) - LENGTH(REPLACE(short_precis, ' ', ''))+1), 0) short_precis_words 
  FROM programme_items
  where
  IF(LENGTH(title) > 0, (LENGTH(title) - LENGTH(REPLACE(title, ' ', ''))+1), 0) > %d OR
  IF(LENGTH(short_title) > 0, (LENGTH(short_title) - LENGTH(REPLACE(short_title, ' ', ''))+1), 0) > %d OR
  IF(LENGTH(precis) > 0, (LENGTH(precis) - LENGTH(REPLACE(precis, ' ', ''))+1), 0) > %d OR
  IF(LENGTH(short_precis) > 0, (LENGTH(short_precis) - LENGTH(REPLACE(short_precis, ' ', ''))+1), 0) > %d;
EOS

PEOPLE_TAG_QUERY = <<"EOS"
  select taggings.context as context, tags.name as tag, 
  people.first_name as first_name, people.last_name as last_name, people.suffix as suffix,
  pseudonyms.first_name as pub_first_name, pseudonyms.last_name as pub_last_name, pseudonyms.suffix as pub_suffix
  from tags 
  join taggings on taggings.tag_id = tags.id and taggings.taggable_type = 'Person'
  join people on people.id = taggings.taggable_id
  left join pseudonyms on pseudonyms.person_id = people.id
  order by taggings.context, tags.name, people.last_name;
EOS

  
end
