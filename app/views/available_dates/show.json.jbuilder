
if @availableDate
    json.id             @availableDate.id
    json.lock_version   @availableDate.lock_version
    json.end_time       @availableDate.end_time
    json.start_time     @availableDate.start_time

    json.start_time_str @availableDate.start_time.strftime('%A, %B %e %Y,%l:%M %p')
    json.end_time_str   (@availableDate.end_time ? @availableDate.end_time.strftime('%A, %B %e %Y,%l:%M %p') : nil);
end
