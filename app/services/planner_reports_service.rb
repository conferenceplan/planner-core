#
#
#
module PlannerReportsService

  #
  #
  #
  def self.findPanelsWithPanelists(sort_by = '', mod_date = '1900-01-01', format_id = nil, sched_only = false, equip_only = false, plus_setups = false)

    cond_str = "(programme_items.updated_at >= ? or programme_item_assignments.updated_at >= ? or (programme_items.updated_at is NULL and programme_items.created_at >= ?) or (programme_item_assignments.updated_at is NULL and programme_item_assignments.created_at >= ?))"
    cond_str << " and time_slots.start is not NULL" if sched_only

    conditions = [mod_date, mod_date, mod_date, mod_date]

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
  def self.findPanelistsWithPanels(peopleIds = nil, additional_roles = nil, scheduledOnly = false, visibleOnly = false)
    roles =  [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id] # ,PersonItemRole['Invisible'].id
    roles.concat(additional_roles) if additional_roles
    cndStr = '(people.acceptance_status_id in (?))'
    cndStr += ' AND (programme_item_assignments.person_id in (?))' if peopleIds
    cndStr += ' AND (time_slots.start is not NULL)' if scheduledOnly
    cndStr += ' AND (programme_items.print = true)' if visibleOnly
    cndStr += ' AND (programme_item_assignments.role_id in (?))' if additional_roles

    conditions = [cndStr, [AcceptanceStatus['Accepted'].id, AcceptanceStatus['Probable'].id]]
    conditions << peopleIds if peopleIds
    conditions << roles if additional_roles
    
    Person.all :conditions => conditions, 
              :include => {:pseudonym => {}, :programmeItemAssignments => {:programmeItem => [:time_slot, :room, :format]}},
              :order => "people.last_name, time_slots.start asc"

  end
  
  #
  #
  #
  def self.findPublishedPanelistsWithPanels(peopleIds = nil, additional_roles = nil)
    roles =  [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id]
    roles.concat(additional_roles) if additional_roles
    cndStr = '(published_programme_item_assignments.role_id in (?)) AND (people.acceptance_status_id in (?))'
    cndStr += ' AND (published_programme_item_assignments.person_id in (?))' if peopleIds

    conditions = [cndStr, roles, [AcceptanceStatus['Accepted'].id, AcceptanceStatus['Probable'].id]]
    conditions << peopleIds if peopleIds
    
    Person.all :conditions => conditions, 
              :include => {:pseudonym => {}, :publishedProgrammeItemAssignments => {:published_programme_item => [:published_time_slot, :published_room, :format]}},
              :order => "people.last_name, published_time_slots.start asc"

  end
  
end
