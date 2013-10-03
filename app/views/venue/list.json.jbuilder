
json.array! @venues do |venue|

    json.partial! 'venue', venue: venue 
    
end
