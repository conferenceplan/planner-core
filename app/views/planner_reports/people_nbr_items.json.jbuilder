json.totalpages 1
json.currpage 1
    
json.rowdata @assignments do |assignment|

    json.name               assignment.person.getFullPublicationName
    json.day                assignment.day
    json.day_str            (Time.zone.parse(SiteConfig.first.start_date.to_s) + assignment.day.day).strftime('%A')
    json.nbr_items          assignment.nbr_items
    json.max_items_per_day  assignment.max_items_per_day ? assignment.max_items_per_day : ''
    json.max_items_per_con  assignment.max_items_per_con ? assignment.max_items_per_day : ''

    # List the items that the person is on for the day in question
    json.items assignment.person.programmeItemAssignments.collect { |pi|
        pi.programmeItem.title if pi.programmeItem && pi.programmeItem.room_item_assignment && 
                                  pi.programmeItem.room_item_assignment.day == assignment.day && 
                                  ([PersonItemRole['Participant'], PersonItemRole['Moderator']].include? pi.role)
    }.reject { |c| c == nil }

end
