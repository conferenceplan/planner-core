#
#
#
json.day @day
json.date @currentDate

json.rooms @roomListing do |room|

    json.id room.id
    json.name room.name
    json.purpose room.purpose
    
    json.items do
        json.array! room.room_item_assignments.day(@day) do |assignment|
            json.assignment_id assignment.id
            json.room_id room.id
            json.time_id assignment.time_slot.id
            json.item_id assignment.programme_item.id
            
            json.time assignment.time_slot.start
            json.duration assignment.programme_item.duration
            
            json.title assignment.programme_item.title
            
            json.day assignment.day
        end
    end
    
end
