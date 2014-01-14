xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.program do
    @times.chunk { |n| n.start }.each do |items|
        xml.time do
            xml.start do
                xml.day items[0].strftime('%A')
                xml.time items[0].strftime('%H:%M')
            end
            items[1].each do |item|
                xml.item do
                    xml.room item.rooms[0].name
                    xml.venue item.rooms[0].venue.name
                    xml.details do
                        xml.reference_number item.programme_items[0].pub_reference_number
                        xml.duration item.programme_items[0].duration
                        xml.format item.programme_items[0].format.name
                        xml.tracks do
                            item.programme_items[0].tag_list_on(:PrimaryArea).each do |track| # TODO - check to make sure we have PrimaryArea
                                xml.track track
                            end
                        end
                        xml.title item.programme_items[0].title
                        xml.short_title item.programme_items[0].short_title
                        xml.description item.programme_items[0].precis
                        xml.people do # we want the moderators and then participants
                            item.programme_items[0].programme_item_assignments.find_all {|x| x.role == PersonItemRole['Moderator'] }.each do |p|
                                xml.moderator p.person.getFullPublicationName
                            end
                            item.programme_items[0].programme_item_assignments.find_all {|x| x.role == PersonItemRole['Participant'] }.each do |p|
                                xml.participant p.person.getFullPublicationName
                            end
                        end
                    end
                end
            end
        end
    end
end
