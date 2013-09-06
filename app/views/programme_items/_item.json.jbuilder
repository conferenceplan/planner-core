#
#
#

json.id                     item.id    
json.title                  item.title    
json.short_title            item.short_title
json.precis                 item.precis
json.notes                  item.notes
json.pub_reference_number   item.pub_reference_number
json.print                  item.print
json.duration               item.duration
json.maximum_people         item.maximum_people
json.minimum_people         item.minimum_people
json.setup_type_id          item.setup_type_id
json.setup_name             item.setup_type ? item.setup_type.name : "" 
json.format_id              item.format_id
json.format_name            item.format ? item.format.name : ""
    
json.start_day              item.room_item_assignment ? item.room_item_assignment.day : "" # we want this to be the number
json.start_day_str          item.time_slot ? item.time_slot.start.strftime('%A') : "" # we want this to be the number
json.start_time             item.time_slot ? item.time_slot.start.strftime('%H:%M') : ""
json.pub_reference_number   item.pub_reference_number

# TODO - do we want just the name or do we want the actual id or entity?
json.room                   item.room ? item.room.name : ""
json.room_id                item.room ? item.room.id : ""
    
json.lock_version           item.lock_version

# TODO - do we want to list the participants?
if moderators
    json.moderators moderators.collect { |p| p.person }
end
if participants
    json.participants participants.collect { |p| p.person }
end
if reserves
    json.reserves reserves.collect { |p| p.person }
end
if invisibles
    json.invisibles invisibles.collect { |p| p.person }
end
