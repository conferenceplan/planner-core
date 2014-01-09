json.totalpages 1
json.currpage 1
    
json.rowdata @people do |person|
    json.name               person.getFullPublicationName
    json.acceptance_status  person.acceptance_status.name
    json.items              person.programmeItemAssignments.collect { |pi|
        if (pi.programmeItem)
            (pi.programmeItem.pub_reference_number ? pi.programmeItem.pub_reference_number.to_s + ' ' : '' ) +
            '<b>' + pi.programmeItem.title + '</b>' +
            ' (' + pi.programmeItem.format.name + ') ' +
            ' (' + pi.role.name + '), ' +
            (pi.programmeItem.time_slot ? pi.programmeItem.time_slot.start.strftime('%a %H:%M') + ' - ' + pi.programmeItem.time_slot.end.strftime('%H:%M') : '') +
            (pi.programmeItem.room ? ', ' + pi.programmeItem.room.name : '') +
            (pi.programmeItem.room ? ' (' + pi.programmeItem.room.venue.name + ')': '')
        end
    }.reject { |c| c == nil }
end
