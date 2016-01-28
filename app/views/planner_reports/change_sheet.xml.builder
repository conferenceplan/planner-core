#
#
#
xml.changes do

    xml.updated_items do
        @item_changes.each do |k, v|
            if v[:item]
            xml.item do
                xml.id k
                xml.ref_nbr v[:item].pub_reference_number if v[:item].pub_reference_number
                xml.title v[:item].title if v[:item].title
                # item updated - change of title or description
                xml.changes do
                    # Changes to programme items
                    if v[:changed]
                        v[:changed].each do |k, v|
                            if (!v.blank? && (k.to_s != 'created_at'))
                                xml.__send__(k.to_s) do
                                    xml.from v[0]
                                    xml.to v[1]
                                end
                            end
                        end
                    end
                    # people added and/or dropped
                    if v[:people]
                        xml.people do
                            v[:people].each do |person|
                                xml.person do
                                    xml.name person[1][:person_name]
                                    xml.action person[1][:action] 
                                    xml.role person[1][:role] 
                                end
                            end
                        end
                    end
                    # Room and time changes
                    if v[:time]
                        xml.date       v[:time][:time].start.strftime('%Y-%m-%d')
                        xml.time       v[:time][:time].start.strftime('%H:%M')
                        xml.duration (v[:time][:time].end - v[:time][:time].start) / 60
                    end
                    if v[:room]
                        xml.place do
                            xml.room v[:room][:room].name
                            xml.venue v[:room][:room].published_venue.name
                        end
                    end
                end
            end            
        end
        end
    end

    # These have an issue    
    xml.deleted_items do
        @item_changes.keep_if{|k,v| v[:item] == nil}.each do |k, v|
            xml.item do
                xml.title v[:deleted][:title]
            end
        end
    end
    
    xml.new_items do
        @changes[:new_items].each do |item_id|
            item = PublishedProgrammeItem.find(item_id)
                xml.item do
                    xml.room item.published_room.name if item.published_room
                    xml.venue item.published_room.published_venue.name if item.published_room
                    xml.details do
                        xml.reference_number item.pub_reference_number
                        xml.duration item.duration
                        xml.format item.format.name if item.format
                        xml.title item.title
                        xml.description item.precis
                        xml.people do # we want the moderators and then participants
                            item.published_programme_item_assignments.find_all {|x| x.role == PersonItemRole['Moderator'] }.each do |p|
                                xml.moderator p.person.getFullPublicationName
                            end
                            item.published_programme_item_assignments.find_all {|x| x.role == PersonItemRole['Participant'] }.each do |p|
                                xml.participant p.person.getFullPublicationName
                            end
                        end
                    end
                end
        end
    end

    xml.removed_people do
        @changes[:removedPeople].each do |person_id|
            if Person.exists? person_id
                person = Person.find person_id
                xml.person do
                    xml.name person.getFullPublicationName
                end
            end
        end
    end
end
