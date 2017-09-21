json.totalpages 1
json.currpage 1
    
json.rowdata @assignments.reject{|a| a.day == nil } do |assignment|
    
    json.name               assignment.person.getFullPublicationName
    json.company            assignment.person.company
    json.day                assignment.day
    json.day_str            assignment.day ? (Time.zone.parse(SiteConfig.first.start_date.to_s) + assignment.day.day).strftime('%A') : ''
    json.date_str           assignment.day ? (Time.zone.parse(SiteConfig.first.start_date.to_s) + assignment.day.day).strftime('%d %b %Y') : ''
    json.nbr_items          assignment.nbr_items
    json.max_items_per_day  assignment.max_items_per_day ? assignment.max_items_per_day : ''
    json.max_items_per_con  assignment.max_items_per_con ? assignment.max_items_per_con : ''

    # List the items that the person is on for the day in question
    json.items assignment.person.programmeItemAssignments.collect { |pi|
        title = pi.programmeItem.title if pi.programmeItem && 
                                  (
                                  ((pi.programmeItem.parent_id != nil) && 
                                  (pi.programmeItem.parent.room_item_assignment && pi.programmeItem.parent.room_item_assignment.day == assignment.day)) || 
                                  (pi.programmeItem.room_item_assignment && pi.programmeItem.room_item_assignment.day == assignment.day)
                                  ) && 
                                  ([PersonItemRole['Participant'], PersonItemRole['Moderator']].include? pi.role)
        title += ' [' + pi.programmeItem.parent.title + ']' if pi.programmeItem && 
                                  (
                                  ((pi.programmeItem.parent_id != nil) && 
                                  (pi.programmeItem.parent.room_item_assignment && pi.programmeItem.parent.room_item_assignment.day == assignment.day))
                                  ) && 
                                  ([PersonItemRole['Participant'], PersonItemRole['Moderator']].include? pi.role)
        title
    }.reject { |c| c == nil }

end
