json.totalpages 1
json.currpage 1
    
json.rowdata @assignments do |assignment|

    json.title              assignment.programmeItem ? (assignment.programmeItem.title + (assignment.programmeItem.parent ? ' [' + assignment.programmeItem.parent.title + ']' : "")): ''
    json.name               assignment.person.getFullPublicationName
    json.company            assignment.person.company

    # List the items that the person is on for the day in question
    json.items assignment.person.programmeItemAssignments.collect { |pi|
        (pi.programmeItem.title + (pi.programmeItem.parent ? ' [' + pi.programmeItem.parent.title + ']' : "")) if pi.programmeItem && pi.programmeItem.room_item_assignment && 
                                  ([PersonItemRole['Participant'], PersonItemRole['Moderator']].include? pi.role)
    }.reject { |c| c == nil }

end
