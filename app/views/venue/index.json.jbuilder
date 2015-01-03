
json.total @total

json.rows @venues do |venue|

    json.partial! 'venue', venue: venue 
    
end
