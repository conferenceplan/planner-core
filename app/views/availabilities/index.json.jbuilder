
#json.dates @availableDates

if @availableDates
json.dates do
    json.id             @availableDates.id
    json.lock_version   @availableDates.lock_version
    json.end_time       @availableDates.end_time
    json.start_time     @availableDates.start_time

    json.start_time_str @availableDates.start_time.strftime('%A, %B %e %Y,%l:%M %p')
    json.end_time_str   (@availableDates.end_time ? @availableDates.end_time.strftime('%A, %B %e %Y,%l:%M %p') : nil);
end
end
    
json.items @excludedItems
   
json.times @excludedTimesGroup.each do |time|
    json.id             time.id
    json.lock_version   time.lock_version
    json.start          time.start
    json.end            time.end
    json.start_str      time.start.strftime('%A, %B %e %Y,%l:%M %p')
    json.end_str        time.end.strftime('%A, %B %e %Y,%l:%M %p')
end
