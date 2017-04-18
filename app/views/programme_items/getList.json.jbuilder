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
    json.set! "venue", item.room && item.room.venue ? item.room.venue.name : ""
    json.set! "start_day", item.time_slot ? (I18n.t(:"date.day_names")[item.time_slot.start.strftime('%w').to_i] + ', ' +  I18n.l(item.time_slot.start.to_date, format: :short)) : ""
    json.set! "start_time", item.time_slot ? item.time_slot.start.strftime('%H:%M') : ""
    json.set! "programme_item[pub_reference_number]", item.pub_reference_number ? item.pub_reference_number : ""
    json.set! "programme_item[lock_version]", item.lock_version
    
    json.set! "programme_item[participants]", item.programme_item_assignments.collect{|m| (m.role == PersonItemRole['Participant'] || m.role == PersonItemRole['Moderator'])? m : nil}.compact.length

    json.set! "programme_item[children]", (item.children.size > 0)
    json.set! "children", (item.children.size > 0)

    # TODO - we need to test this
    json.theme_name_ids item.theme_names.collect{|c| c.id}
    json.theme_names do
        json.array! item.theme_names do |n|
            json.id     n.id
            json.name   n.name
        end
    end

end
