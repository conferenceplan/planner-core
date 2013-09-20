#
#
#
            json.assignment_id @assignment.id
            json.room_id @assignment.room.id
            json.time_id @assignment.time_slot.id
            json.item_id @assignment.programme_item.id
            
            json.time @assignment.time_slot.start
            json.duration @assignment.programme_item.duration
            
            json.title @assignment.programme_item.title
            
            json.day @assignment.day
