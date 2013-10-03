
    json.id                 setup.id
    json.capacity           setup.capacity
    json.room_id            setup.room_id
    json.setup_type_id      setup.setup_type_id
    json.setup_type_name    setup.setup_type ? setup.setup_type.name : ''
    json.isdefault          setup.id == setup.room.setup_id 
    json.lock_version       setup.lock_version
    
    json.room               setup.room
