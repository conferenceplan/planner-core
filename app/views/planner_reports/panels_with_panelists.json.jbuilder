
json.totalpages 1
json.currpage 1
    
json.rowdata @panels.collect { |panel|
    count = panel.programme_item_assignments.length
    next if (@fewer_than > 0 && count >= @fewer_than)
    next if (@more_than > 0 && count <= @more_than)
    
    panel
}.compact do |panel|
    if panel.time_slot
        json.date       panel.start_time.strftime('%d %b %Y')
        json.day        panel.start_time.strftime('%A')
        json.start_time panel.start_time.strftime(@plain_time_format)
        json.end_time   panel.end_time.strftime(@plain_time_format)
    end

    json.room_name panel.room.name if panel.room
    json.venue_name panel.room.venue.name if panel.room
    
    json.format (panel.format ? panel.format.name : '')

#    json.pub_reference_number panel.pub_reference_number
    json.title panel.title

#    json.description panel.description
#    json.minimum_people panel.minimum_people
#    json.maximum_people panel.maximum_people
#    json.context panel.taggings.collect{|t| t.context}.uniq
    json.nbr_participants panel.programme_item_assignments.select{|pi| 
      pi.role == PersonItemRole['Participant'] || 
      pi.role == PersonItemRole['OtherParticipant'] ||
      pi.role == PersonItemRole['Moderator']}.count
    
    json.participants panel.programme_item_assignments.select{|pi| 
      pi.role == PersonItemRole['Participant'] || 
      pi.role == PersonItemRole['OtherParticipant'] }.collect {|p| 
            p.person.getFullPublicationName + (p.person.registrationDetail && p.person.registrationDetail.registered  ? " (Registered)" : '') 
            }
    json.moderators panel.programme_item_assignments.select{|pi| pi.role == PersonItemRole['Moderator']}.collect {|p| 
            p.person.getFullPublicationName + (p.person.registrationDetail && p.person.registrationDetail.registered  ? " (Registered)" : '') 
            }
#    json.reserve panel.programme_item_assignments.select{|pi| pi.role == PersonItemRole['Reserved']}.collect {|p| p.person.getFullPublicationName + (!p.person.company.blank? ? ' (' + p.person.company + ')' : '')}
#    json.invisible panel.programme_item_assignments.select{|pi| pi.role == PersonItemRole['Invisible']}.collect {|p| p.person.getFullPublicationName + (!p.person.company.blank? ? ' (' + p.person.company + ')' : '')}
end
