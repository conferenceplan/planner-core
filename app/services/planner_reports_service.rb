#
#
#
module PlannerReportsService

  #
  #
  #  
  def self.findPanelistsWithPanels(peopleIds = nil, additional_roles = nil, scheduledOnly = false)
    roles =  [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id,PersonItemRole['Invisible'].id]
    roles.concat(additional_roles) if additional_roles
    cndStr = '(programme_item_assignments.role_id in (?)) AND (people.acceptance_status_id in (?))'
    cndStr += ' AND (programme_item_assignments.person_id in (?))' if peopleIds
    cndStr += ' AND (time_slots.start is not NULL)' if scheduledOnly

    conditions = [cndStr, roles, [AcceptanceStatus['Accepted'].id, AcceptanceStatus['Probable'].id]]
    conditions << peopleIds if peopleIds
    
    Person.all :conditions => conditions, 
              :include => {:pseudonym => {}, :programmeItemAssignments => {:programmeItem => [:time_slot, :room, :format]}},
              :order => "people.last_name, time_slots.start asc"

  end
  
  #
  #
  #
  def self.findPublishedPanelistsWithPanels(peopleIds = nil, additional_roles = nil)
    roles =  [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id,PersonItemRole['Invisible'].id]
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
