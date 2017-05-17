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
    json.set! "start_day", item.start_time ? (I18n.t(:"date.day_names")[item.start_time.strftime('%w').to_i] + ', ' +  I18n.l(item.start_time.to_date, format: :short)) : ""
    json.set! "start_time", item.start_time ? item.start_time.strftime('%H:%M') : ""
    json.set! "programme_item[pub_reference_number]", item.pub_reference_number ? item.pub_reference_number : ""
    json.set! "programme_item[lock_version]", item.lock_version

    json.set! "programme_item[participants]", item.programme_item_assignments.collect{|m| (m.role == PersonItemRole['Participant'] || m.role == PersonItemRole['OtherParticipant'] || m.role == PersonItemRole['Moderator'])? m : nil}.compact.length
    json.set! "programme_item[visibility]", t('item-visibility.' + item.visibility_name.downcase) if item.visibility
end
