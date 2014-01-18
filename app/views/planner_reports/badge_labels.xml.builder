xml.badge_labels do
    @people.each do |person|
        # should be the published items
        xml.person do
            xml.name(person.getFullPublicationName)
            xml.items do
                person.programmeItems.each do |item|
                    xml.item do
                        xml.title item.title
                        xml.format item.format.name
                        xml.room item.room.name
                        xml.venue item.room.venue.name
                        xml.day item.time_slot.start.strftime('%A')
                        xml.time item.time_slot.start.strftime('%H:%M')
                        xml.date item.time_slot.start.strftime('%y-%m-%d')
                    end
                end
            end
        end
    end
end
