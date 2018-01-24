
json.id                 setup.id
json.capacity           setup.capacity
json.room_id            setup.room_id
json.setup_type_id      setup.setup_type_id
json.setup_type_name    setup.setup_type ? setup.setup_type.name : ''
json.isdefault          setup.room ? (setup.id == setup.room.setup_id) : false 
json.lock_version       setup.lock_version

room = setup.room
if room
  json.room do
    json.id room.id
    json.lock_version room.lock_version
    json.venue_id room.venue_id
    json.name room.name
    json.purpose room.purpose
    json.comment room.comment
    json.setup_id room.setup_id
    json.base_room_id room.base_room_id
    json.sort_order room.sort_order
  end
else
  json.room nil
end
