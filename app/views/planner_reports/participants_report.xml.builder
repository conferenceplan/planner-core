xml.participants do
    @people.each do |person|
        # should be the published items
        xml.person do
            xml.name(person.getFullPublicationName)
            xml.job_title(person.job_title)
            xml.company(person.company)
            xml.photo_url(person.bio_image ? person.bio_image.bio_picture.url : '')
            xml.bio(person.bio)
            xml.items do
                person.programmeItemAssignments.each do |assignment|
                    if assignment.programmeItem.time_slot && (@allowed_roles.include? assignment.role)
                        xml.item do
                            xml.role assignment.role.name if assignment.role
                            xml.title assignment.programmeItem.short_title.blank? ? assignment.programmeItem.title : assignment.programmeItem.short_title
                            xml.format assignment.programmeItem.format ? assignment.programmeItem.format.name : ''
                            xml.room assignment.programmeItem.room.name
                            xml.venue assignment.programmeItem.room.venue.name
                            xml.day assignment.programmeItem.time_slot.start.strftime('%A')
                            xml.time assignment.programmeItem.time_slot.start.strftime('%H:%M')
                            xml.date assignment.programmeItem.time_slot.start.strftime('%y-%m-%d')
                            xml.notes assignment.programmeItem.participant_notes
                        end
                    end
                end
            end
        end
    end
end