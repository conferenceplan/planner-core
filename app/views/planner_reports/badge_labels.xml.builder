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
                                xml.role assignment.role.name
                                xml.title assignment.programmeItem.short_title.blank? ? assignment.programmeItem.title : assignment.programmeItem.short_title
                                xml.format assignment.programmeItem.format.name if assignment.programmeItem.format
                                if assignment.programmeItem.time_slot
                                    xml.room assignment.programmeItem.room.name
                                    xml.venue assignment.programmeItem.room.venue.name
                                    xml.day assignment.programmeItem.time_slot.start.strftime('%A')
                                    xml.time assignment.programmeItem.time_slot.start.strftime('%H:%M')
                                    xml.date assignment.programmeItem.time_slot.start.strftime('%y-%m-%d')
                                else
                                    xml.room assignment.programmeItem.parent.room.name
                                    xml.venue assignment.programmeItem.parent.room.venue.name
                                    xml.day assignment.programmeItem.parent.time_slot.start.strftime('%A')
                                    xml.time assignment.programmeItem.parent.time_slot.start.strftime('%H:%M')
                                    xml.date assignment.programmeItem.parent.time_slot.start.strftime('%y-%m-%d')
                                    
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
end
