#
#
#
xml.room_signs do
    days = @day ? [@day] : (0..((SITE_CONFIG[:conference][:number_of_days]).to_i-1)).to_a
    days.each do |day| # For each day ...
        @rooms.each do |room|
            xml.room do
                xml.room_name room.name
                xml.venue room.published_venue.name if room.published_venue
                xml.day (Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + day.days).strftime('%A')
                xml.items do
                    room.published_room_item_assignments.day(day).each do |assignment|
                        xml.item do
                            xml.start do
                                xml.day assignment.published_time_slot.start.strftime('%A')
                                xml.time assignment.published_time_slot.start.strftime('%H:%M')
                            end
                            xml.end assignment.published_time_slot.end
                            xml.title assignment.published_programme_item.title
                            xml.participants do # Participants (Moderators etc)
                                assignment.published_programme_item.published_programme_item_assignments.collect {|a| ([PersonItemRole['Participant'],PersonItemRole['Moderator']].include? a.role) ? a : nil}.compact.each do |p|
                                    xml.participant do
                                        xml.name p.person.getFullPublicationName
                                        xml.role p.role.name
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
