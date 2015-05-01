
json.array!(@assignments) do |assignment|
    if assignment.programmeItem
        json.id                     assignment.programmeItem.id
        json.lock_version           assignment.programmeItem.lock_version
        json.title                  assignment.programmeItem.title
        json.short_title            assignment.programmeItem.short_title
        json.precis                 assignment.programmeItem.precis
        json.duration               assignment.programmeItem.duration
        json.format_id              assignment.programmeItem.format.id if assignment.programmeItem.format
        json.format_name            assignment.programmeItem.format.name if assignment.programmeItem.format
        json.maximum_people         assignment.programmeItem.maximum_people
        json.minimum_people         assignment.programmeItem.minimum_people
        json.item_notes             assignment.programmeItem.item_notes
        json.print                  assignment.programmeItem.print
        json.pub_reference_number   assignment.programmeItem.pub_reference_number
        json.isPublished            assignment.programmeItem.published != nil
        json.start_time_str         assignment.programmeItem.time_slot ? assignment.programmeItem.time_slot.start.strftime('%A, %B %e %Y, %l:%M %P') : ""
        json.time_slot              assignment.programmeItem.time_slot
        json.room                   assignment.programmeItem.room
        json.venue                  assignment.programmeItem.room.venue if assignment.programmeItem.room
        json.setup_type_id          assignment.programmeItem.setup_type.id if assignment.programmeItem.setup_type
        json.setup_type_name        assignment.programmeItem.setup_type.name if assignment.programmeItem.setup_type
        json.role                   assignment.role.name
        json.other_participants     assignment.programmeItem.people.collect{|p| p != @person ? p.getFullPublicationName : nil }.compact
    end
end
