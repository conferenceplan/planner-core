json.totalpages 1
json.currpage 1
    
json.rowdata @people do |person|
    json.name               person.getFullPublicationName
    json.company            person.company
    json.email              person.getDefaultEmail ? person.getDefaultEmail.email : ''
    json.acceptance_status  person.acceptance_status.name if person.acceptance_status
    json.registered         person.registrationDetail.registered if person.registrationDetail
    json.registration_number    person.registrationDetail.registration_number if person.registrationDetail
    json.items              person.programmeItemAssignments.
                    sort_by{ |a| (a.programmeItem.start_time ? a.programmeItem.start_time : @conf_start_time) }.
                    collect { |pi|
        if (pi.programmeItem)
            (pi.programmeItem.pub_reference_number ? pi.programmeItem.pub_reference_number.to_s + ' ' : '' ) +
            '<b>' + pi.programmeItem.title + '</b>' +
            ( pi.programmeItem.format ? ' (' + pi.programmeItem.format.name + ') ' : '' ) +
            ' (' + pi.role.name + ')' +
            (pi.programmeItem.start_time ? ', ' + pi.programmeItem.start_time.strftime(@time_format) + ' - ' + pi.programmeItem.end_time.strftime(@plain_time_format) : '') +
            (pi.programmeItem.room ? ', ' + pi.programmeItem.room.name : '') +
            (pi.programmeItem.room ? ' (' + pi.programmeItem.room.venue.name + ')': '') +
            (pi.programmeItem.parent ?
                ' <em>part of<em> ' +
                (pi.programmeItem.parent.pub_reference_number ? pi.programmeItem.parent.pub_reference_number.to_s + ' ' : '' ) +
                '<b>' + pi.programmeItem.parent.title + '</b>' +
                ( pi.programmeItem.parent.format ? ' (' + pi.programmeItem.parent.format.name + ') ' : '' ) +
                (pi.programmeItem.parent.time_slot ? ' ' + pi.programmeItem.parent.start_time.strftime(@time_format) + ' - ' + pi.programmeItem.parent.end_time.strftime(@plain_time_format) : '') +
                (pi.programmeItem.parent.room ? ', ' + pi.programmeItem.parent.room.name : '') +
                (pi.programmeItem.parent.room ? ' (' + pi.programmeItem.parent.room.venue.name + ')': '') : ''
            )
        end
    }.reject { |c| c == nil }
end
