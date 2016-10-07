xml.badge_labels do
    @people.each do |person|
        # should be the published items
        xml.person do
            xml.name(person.getFullPublicationName)
            xml.items do
                person.programmeItemAssignments.
                sort_by{ |a| (a.programmeItem.parent && a.programmeItem.parent.time_slot) ? a.programmeItem.parent.time_slot.start : (a.programmeItem.time_slot ? a.programmeItem.time_slot.start : @conf_start_time) }.
                each do |assignment|
                    if @allowed_roles.include? assignment.role
                        xml.item do
                            xml.role (assignment.description.blank? ? assignment.role.name : assignment.description) if assignment.role
                            xml.title assignment.programmeItem.short_title.blank? ? assignment.programmeItem.title : assignment.programmeItem.short_title
                            xml.format assignment.programmeItem.format ? assignment.programmeItem.format.name : ''

                            if assignment.programmeItem.parent
                                if assignment.programmeItem.parent.room
                                    xml.room assignment.programmeItem.parent.room.name
                                    xml.venue assignment.programmeItem.parent.room.venue.name
                                end
                            else
                                if assignment.programmeItem.room
                                    xml.room assignment.programmeItem.room.name
                                    xml.venue assignment.programmeItem.room.venue.name
                                end
                            end

                            xml.day assignment.programmeItem.start_time.strftime('%A')
                            xml.time assignment.programmeItem.start_time.strftime('%H:%M')
                            xml.date assignment.programmeItem.start_time.strftime('%y-%m-%d')

                            xml.notes assignment.programmeItem.participant_notes
                            if assignment.programmeItem.parent
                                xml.parent do
                                    xml.title assignment.programmeItem.parent.title
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
