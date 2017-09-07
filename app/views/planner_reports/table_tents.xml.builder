xml.table_tent do
    if @people
        @people.each do |person|
            # should be the published items
            xml.person do
                xml.name(person.getFullPublicationName)
                xml.items do
                    person.published_programme_items.collect{|i| @itemList ? (@itemList.include?(i.id.to_s) ? i : nil) : i }.compact.
                        sort_by{ |a| a.start_time ? a.start_time :  @conf_start_time }.
                        each do |item|
                            xml.item do
                                xml.title item.title
                                xml.description item.precis if item.precis
                                xml.format item.format.name if item.format
    
                                if item.parent
                                    xml.room item.parent.published_room.name
                                    xml.venue item.parent.published_room.published_venue.name
                                else
                                    xml.room item.published_room.name
                                    xml.venue item.published_room.published_venue.name
                                end
                                xml.day item.start_time.strftime('%A')
                                xml.time item.start_time.strftime('%H:%M')
                                xml.date item.start_time.strftime('%y-%m-%d')
                            end
                    end
                end
            end
        end
    end
end
