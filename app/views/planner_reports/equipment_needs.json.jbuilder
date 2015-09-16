
json.totalpages 1
json.currpage 1
    
json.rowdata @panels do |panel|
    json.pub_reference_number panel.pub_reference_number
    if panel.parent
        json.title panel.title + " [" + panel.parent.title + "]"
    else
        json.title panel.title
    end
    json.description panel.precis
    json.minimum_people panel.minimum_people
    json.maximum_people panel.maximum_people
    json.format (panel.format ? panel.format.name : '')
    if panel.time_slot
        json.date       panel.time_slot.start.strftime('%d %b %Y')
        json.day        panel.time_slot.start.strftime('%A')
        json.start_time panel.time_slot.start.strftime('%H:%M')
        json.end_time   panel.time_slot.end.strftime('%H:%M')
        json.room_name  panel.room.name if panel.room
        json.room_setup panel.room.room_setup.setup_type.name if panel.room && panel.room.room_setup
        json.venue_name panel.room.venue.name if panel.room
    elsif panel.parent && panel.parent.time_slot
        json.date       panel.parent.time_slot.start.strftime('%d %b %Y')
        json.day        panel.parent.time_slot.start.strftime('%A')
        json.start_time panel.parent.time_slot.start.strftime('%H:%M')
        json.end_time   panel.parent.time_slot.end.strftime('%H:%M')
        json.room_name  panel.parent.room.name if panel.parent.room
        json.room_setup panel.parent.room.room_setup.setup_type.name if panel.parent.room && panel.parent.room.room_setup
        json.venue_name panel.parent.room.venue.name if panel.parent.room
    end
    json.equipment panel.equipment_needs.collect {|e| e.equipment_type.description if e.equipment_type } # TODO - need the name/type of equipment listed here
end
