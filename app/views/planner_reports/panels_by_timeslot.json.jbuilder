json.totalpages 1
json.currpage 1

json.rowdata @times.collect {|t| t.programme_items.collect {|i| { :time => t, :item => i } } }.flatten do |e|
    json.day        e[:time].start.strftime('%a')
    json.time_slot  e[:time].start.strftime('%H:%M') + ' - ' + e[:time].end.strftime('%H:%M')
    json.room       e[:item].room.name
    json.venue      e[:item].room.venue.name
    json.item       e[:item].title
    json.equipment  e[:item].equipment_needs.collect {|eq| eq.equipment_type.description if eq.equipment_type }
end
