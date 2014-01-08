
json.totalpages 1
json.currpage 1
    
json.rowdata @panels.collect { |panel|
    count = panel.programme_item_assignments.length
    next if (@fewer_than > 0 && count > @fewer_than)
    next if (@more_than > 0 && count < @more_than)
    
    panel
}.compact do |panel|
    json.pub_reference_number panel.pub_reference_number
    json.title panel.title
    json.description panel.precis
    json.minimum_people panel.minimum_people
    json.maximum_people panel.maximum_people
    json.format (panel.format ? panel.format.name : '')
    json.context panel.taggings.collect{|t| t.context}.uniq
    if panel.time_slot
        json.start_time panel.time_slot.start.strftime('%a %H:%M')
        json.end_time panel.time_slot.end.strftime('%a %H:%M')
    end
    json.room_name panel.room.name if panel.room
    json.venue_name panel.room.venue.name if panel.room
    json.equipment panel.equipment_needs.collect {|e| e.equipment_type.description if e.equipment_type } # TODO - need the name/type of equipment listed here
    
    json.participants panel.programme_item_assignments.select{|pi| pi.role == PersonItemRole['Participant']}.collect {|p| p.person.getFullPublicationName }
    json.moderators panel.programme_item_assignments.select{|pi| pi.role == PersonItemRole['Moderator']}.collect {|p| p.person.getFullPublicationName }
    json.reserve panel.programme_item_assignments.select{|pi| pi.role == PersonItemRole['Reserved']}.collect {|p| p.person.getFullPublicationName }
    json.invisible panel.programme_item_assignments.select{|pi| pi.role == PersonItemRole['Invisible']}.collect {|p| p.person.getFullPublicationName }
end
