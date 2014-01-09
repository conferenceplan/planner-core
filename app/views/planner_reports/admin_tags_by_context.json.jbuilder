json.totalpages 1
json.currpage 1
    
json.rowdata @peopleAndTags do |p|
    json.name p.getFullPublicationName
    json.tags p.details
end
