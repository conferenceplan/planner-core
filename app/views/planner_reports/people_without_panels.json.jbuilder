json.totalpages 1
json.currpage 1
    
json.rowdata @people do |person|
    json.name               person.getFullPublicationName
    json.acceptance_status  person.acceptance_status.name
end
