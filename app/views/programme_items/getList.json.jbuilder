json.totalpages @nbr_pages
json.currpage @page
json.totalrecords @count
    
json.rowdata @items do |item|
    
    json.id item.id
    json.set! "item[title]", item.title
    json.set! "programme_item[format_id]", item.format.id
    json.set! "programme_item[format_name]", item.format.name
    json.set! "programme_item[duration]", item.duration
    json.set! "room", item.room ? item.room.name : ""
    json.set! "start_day", item.time_slot ? item.time_slot.start.strftime('%A') : "" 
    json.set! "start_time", item.time_slot ? item.time_slot.start.strftime('%H:%M') : ""
    json.set! "programme_item[pub_reference_number]", item.pub_reference_number
    json.set! "programme_item[lock_version]", item.lock_version

end
