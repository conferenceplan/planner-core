#
#
#
json.schedule @conflicts do |conflict|
    json.room_id                conflict['room_id']
    json.room_name              conflict['room_name']
    json.person_id              conflict['person_id']
    json.person_name            conflict['person_first_name'] + ' ' + conflict['person_last_name']
    json.item_id                conflict['item_id']
    json.item_title             conflict['item_name']
    json.item_role              PersonItemRole.find(conflict['item_role'].to_i).name
    json.item_start             Time.zone.parse( conflict['item_start'].to_s )
    json.conflict_room_id       conflict['conflict_room_id']
    json.conflict_room_name     conflict['conflict_room_name']
    json.conflict_item_id       conflict['conflict_item_id']
    json.conflict_item_title    conflict['conflict_item_title']
    json.conflict_item_role     PersonItemRole.find(conflict['conflict_item_role'].to_i).name
    json.conflict_start         Time.zone.parse( conflict['conflict_start'].to_s )
    json.item_start_string      Time.zone.parse( conflict['item_start'].to_s ).strftime('%H:%M')
    json.item_day_string        Time.zone.parse( conflict['item_start'].to_s ).strftime('%A')
    json.conflict_start_string  Time.zone.parse( conflict['conflict_start'].to_s ).strftime('%H:%M')
    json.conflict_day_string    Time.zone.parse( conflict['item_start'].to_s ).strftime('%A')
end

json.room @roomConflicts do |conflict|
    json.room_id                conflict['room_id']
    json.room_name              conflict['room_name']
    json.item_id                conflict['item_id']
    json.item_title             conflict['item_name']
    json.conflict_item_id       conflict['conflict_item_id']
    json.conflict_item_title    conflict['conflict_item_name']
    json.item_start             Time.zone.parse( conflict['item_start'].to_s )
    json.conflict_start         Time.zone.parse( conflict['conflict_start'].to_s )
    json.item_start_string      Time.zone.parse( conflict['item_start'].to_s ).strftime('%H:%M')
    json.item_day_string        Time.zone.parse( conflict['item_start'].to_s ).strftime('%A')
    json.conflict_start_string  Time.zone.parse( conflict['conflict_start'].to_s ).strftime('%H:%M')
    json.conflict_day_string    Time.zone.parse( conflict['item_start'].to_s ).strftime('%A')
end

json.excluded_item @excludedItemConflicts do |conflict|
    json.person_id              conflict['person_id']
    json.person_name            conflict['person_first_name'] + ' ' + conflict['person_last_name']
    
    json.room_id                conflict['conflict_room_id']
    json.room_name              conflict['conflict_room_name']
    json.item_id                conflict['conflict_item_id']
    json.item_title             conflict['conflict_item_title']
    json.item_start             Time.zone.parse( conflict['conflict_start'].to_s )
    
    json.conflict_room_id       conflict['room_id']
    json.conflict_room_name     conflict['room_name']
    json.conflict_item_id       conflict['item_id']
    json.conflict_item_title    conflict['item_name']
    json.conflict_start         Time.zone.parse( conflict['item_start'].to_s )
    
    json.item_start_string      Time.zone.parse( conflict['item_start'].to_s ).strftime('%H:%M')
    json.item_day_string        Time.zone.parse( conflict['item_start'].to_s ).strftime('%A')
    json.conflict_start_string  Time.zone.parse( conflict['conflict_start'].to_s ).strftime('%H:%M')
    json.conflict_day_string    Time.zone.parse( conflict['item_start'].to_s ).strftime('%A')
    json.item_role              PersonItemRole.find(conflict['item_role'].to_i).name
end

json.excluded_time @excludedTimeConflicts do |conflict|
    json.room_id                conflict['room_id']
    json.room_name              conflict['room_name']
    json.person_id              conflict['person_id']
    json.person_name            conflict['person_first_name'] + ' ' + conflict['person_last_name']
    json.item_id                conflict['item_id']
    json.item_title             conflict['item_name']
    json.item_start             Time.zone.parse( conflict['item_start'].to_s )
    json.period_start           Time.zone.parse( conflict['period_start'].to_s )
    json.period_end             Time.zone.parse( conflict['period_end'].to_s )
    json.item_role              PersonItemRole.find(conflict['item_role'].to_i).name
    json.item_start_string      Time.zone.parse( conflict['item_start'].to_s ).strftime('%H:%M')
    json.item_day_string        Time.zone.parse( conflict['item_start'].to_s ).strftime('%A')
    json.period_start_string    Time.zone.parse( conflict['period_start'].to_s ).strftime('%H:%M')
    json.period_end_string      Time.zone.parse( conflict['period_end'].to_s ).strftime('%H:%M')
end

json.availability @availableTimeConflicts do |conflict|
    json.room_id                conflict['room_id']
    json.room_name              conflict['room_name']
    json.person_id              conflict['person_id']
    json.person_name            conflict['person_first_name'] + ' ' + conflict['person_last_name']
    json.item_id                conflict['item_id']
    json.item_title             conflict['item_name']
    json.item_start             Time.zone.parse( conflict['item_start'].to_s )
    json.period_start           Time.zone.parse( conflict['period_start'].to_s )
    json.period_end             Time.zone.parse( conflict['period_end'].to_s )
    json.period_start_string    Time.zone.parse( conflict['period_start'].to_s ).strftime('%A %H:%M')
    json.period_end_string      Time.zone.parse( conflict['period_end'].to_s ).strftime('%A %H:%M')
    json.item_role              PersonItemRole.find(conflict['item_role'].to_i).name
    json.item_start_string      Time.zone.parse( conflict['item_start'].to_s ).strftime('%H:%M')
    json.item_day_string        Time.zone.parse( conflict['item_start'].to_s ).strftime('%A')
end

json.back_to_back @backtobackConflicts do |conflict|
    json.room_id                conflict['room_id']
    json.room_name              conflict['room_name']
    json.person_id              conflict['person_id']
    json.person_name            conflict['person_first_name'] + ' ' + conflict['person_last_name']
    json.item_id                conflict['item_id']
    json.item_title             conflict['item_name']
    json.item_start             Time.zone.parse( conflict['item_start'].to_s )
    json.conflict_room_id       conflict['conflict_room_id']
    json.conflict_room_name     conflict['conflict_room_name']
    json.conflict_item_id       conflict['conflict_item_id']
    json.conflict_item_title    conflict['conflict_item_title']
    json.conflict_start         Time.zone.parse( conflict['conflict_start'].to_s )
    json.item_role              PersonItemRole.find(conflict['item_role'].to_i).name
    json.conflict_item_role     PersonItemRole.find(conflict['conflict_item_role'].to_i).name
    json.item_start_string      Time.zone.parse( conflict['item_start'].to_s ).strftime('%H:%M')
    json.item_day_string        Time.zone.parse( conflict['item_start'].to_s ).strftime('%A')
    json.conflict_start_string  Time.zone.parse( conflict['conflict_start'].to_s ).strftime('%H:%M')
    json.conflict_day_string    Time.zone.parse( conflict['item_start'].to_s ).strftime('%A')
end
