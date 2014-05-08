json.totalpages 1
json.currpage 1
    
json.rowdata @assignments do |assignment|

    json.name               assignment.person.getFullPublicationName
    json.nbr_items          assignment.nbr_items
    json.max_items_per_day  assignment.max_items_per_day ? assignment.max_items_per_day : ''
    json.max_items_per_con  assignment.max_items_per_con ? assignment.max_items_per_con : ''

    # List the items that the person is on for the day in question
    json.items assignment.person.programmeItemAssignments.collect { |pi|
        pi.programmeItem.title if pi.programmeItem && pi.programmeItem.room_item_assignment && 
                                  ([PersonItemRole['Participant'], PersonItemRole['Moderator']].include? pi.role)
    }.reject { |c| c == nil }

end
