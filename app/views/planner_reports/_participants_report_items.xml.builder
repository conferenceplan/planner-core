builder.items do
    assignments.
      sort_by{ |a| (a.programmeItem.parent && a.programmeItem.parent.time_slot) ? a.programmeItem.parent.time_slot.start : (a.programmeItem.time_slot ? a.programmeItem.time_slot.start : @conf_start_time) }.
      each do |assignment|
        if assignment.programmeItem && (@allowed_roles.include? assignment.role)
            builder.item do
                builder.reference_number assignment.programmeItem.pub_reference_number if assignment.programmeItem.pub_reference_number
                builder.role assignment.role.name if assignment.role
                builder.title do
                    builder.cdata!(assignment.programmeItem.short_title.blank? ? assignment.programmeItem.title : assignment.programmeItem.short_title)
                end
                builder.description do
                    builder.cdata!(assignment.programmeItem.precis) if assignment.programmeItem.precis
                end
                builder.format assignment.programmeItem.format ? assignment.programmeItem.format.name : ''
                builder.room assignment.programmeItem.room.name if assignment.programmeItem.room
                builder.venue assignment.programmeItem.room.venue.name if (assignment.programmeItem.room && assignment.programmeItem.room.venue)
                if assignment.programmeItem.time_slot
                    builder.day assignment.programmeItem.time_slot.start.strftime('%A')
                    builder.time assignment.programmeItem.time_slot.start.strftime('%H:%M')
                    builder.date assignment.programmeItem.time_slot.start.strftime('%y-%m-%d')
                else
                    builder.day assignment.programmeItem.parent.time_slot.start.strftime('%A')
                    builder.time assignment.programmeItem.parent.time_slot.start.strftime('%H:%M')
                    builder.date assignment.programmeItem.parent.time_slot.start.strftime('%y-%m-%d')
                end
                if assignment.programmeItem.parent
                    builder.parent do
                        builder.title assignment.programmeItem.parent.title
                    end
                end

                builder.participant_notes assignment.programmeItem.participant_notes
            end
        end
    end
end
