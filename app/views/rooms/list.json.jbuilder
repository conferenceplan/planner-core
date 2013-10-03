json.totalpages @nbr_pages
json.currpage @page
json.totalrecords @count
json.currentSelection @currentId if @currentId
    
json.rowdata @rooms do |room|
    
    json.id                 room.id
    json.venue_id           room.venue_id
    json.room_setup         room.room_setup
    json.setup              room.room_setup ? room.room_setup.setup_type : ''
    json.name               room.name
    json.set! "purpose",    room.purpose if room.purpose
    json.set! "comment",    room.comment if room.comment
    json.lock_version       room.lock_version

end
