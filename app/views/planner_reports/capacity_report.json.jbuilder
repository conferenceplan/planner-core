
json.totalpages 1
json.currpage 1
    
json.rowdata @items do |item|
    json.title          item.title
    json.format         item.format.name if item.format
    if item.time_slot
        json.date       item.time_slot.start.strftime('%d %b %Y')
        json.day        item.time_slot.start.strftime('%A')
        json.start_time item.time_slot.start.strftime('%a %H:%M')
        json.end_time   item.time_slot.end.strftime('%a %H:%M')
    end
    json.room_name      item.room.name if item.room
    json.venue_name     item.room.venue.name if item.room
    json.capacity       item.room.room_setup.capacity if item.room
    json.audience       item.audience_size
end
