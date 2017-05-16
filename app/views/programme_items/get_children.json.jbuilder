json.totalpages @nbr_pages
json.currpage @page
json.totalrecords @count
json.currentSelection @currentId if @currentId
    
json.rowdata @items do |item|
    json.id item.id
    json.set! "item[title]", item.title
    json.set! "programme_item[format_id]", item.format ? item.format.id : nil
    json.set! "programme_item[format_name]", item.format ? item.format.name : ""
    json.set! "programme_item[duration]", item.duration ? item.duration : ""
    json.set! "room", item.room ? item.room.name : ""
    if item.parent.time_slot
        json.set! "start_day", item.start_time.strftime('%A')
        json.set! "start_time", item.start_time.strftime('%H:%M')
    else
        json.set! "start_day", item.time_slot ? item.time_slot.start.strftime('%A') : "" 
        json.set! "start_time", item.time_slot ? item.time_slot.start.strftime('%H:%M') : ""
    end
    json.set! "programme_item[pub_reference_number]", item.pub_reference_number ? item.pub_reference_number : ""
    json.set! "programme_item[lock_version]", item.lock_version

    json.set! "programme_item[participants]", item.programme_item_assignments.collect{|m| (m.role == PersonItemRole['Participant'] || m.role == PersonItemRole['OtherParticipant'] || m.role == PersonItemRole['Moderator'])? m : nil}.compact.length
end
