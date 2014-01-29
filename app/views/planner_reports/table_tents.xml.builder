xml.table_tent do
    @people.each do |person|
        # should be the published items
        xml.person do
            xml.name(person.getFullPublicationName)
            xml.items do
                person.published_programme_items.collect{|i| @itemList ? (@itemList.include?(i.id.to_s) ? i : nil) : i }.compact.each do |item|
                    xml.item do
                        xml.title item.title
                        xml.description item.precis
                        xml.format item.format.name
                        xml.room item.published_room.name
                        xml.venue item.published_room.published_venue.name
                        xml.day item.published_time_slot.start.strftime('%A')
                        xml.time item.published_time_slot.start.strftime('%H:%M')
                        xml.date item.published_time_slot.start.strftime('%y-%m-%d')
                    end
                end
            end
        end
    end
end
