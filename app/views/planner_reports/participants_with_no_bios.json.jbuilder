json.totalpages 1
json.currpage 1
    
json.rowdata @people do |person|
    json.name               person.getFullPublicationName
    json.invitestatus       person.invitestatus.name if person.invitestatus
    json.acceptance_status  person.acceptance_status.name if person.acceptance_status
end
