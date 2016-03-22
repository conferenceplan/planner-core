json.totalpages 1
json.currpage 1
    
json.rowdata @rooms.collect {|r| r.programme_items.collect {|i| { :room => r, :item => i } } }.flatten do |e|
    json.room       e[:room].name
    json.venue      e[:room].venue.name
    json.item       e[:item].title
    json.date       e[:item].time_slot.start.strftime('%d %b %Y')
    json.day        e[:item].time_slot.start.strftime('%a')
    json.start_time e[:item].time_slot.start.strftime('%H:%M')
    json.end_time   e[:item].time_slot.end.strftime('%H:%M')
end
