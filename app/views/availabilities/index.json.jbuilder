
json.dates @availableDates
    
json.items @excludedItems
   
json.times @excludedTimesGroup.each do |time|
    json.id time.id
    json.lock_version time.lock_version
    json.start time.start
    json.end time.end
end

