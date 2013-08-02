json.totalpages @nbr_pages
json.currpage @page
json.totalrecords @count
    
json.rowdata @people do |person|

    
    json.id person.id
    json.first_name person.first_name
    json.last_name person.last_name
    json.suffix person.suffix
    json.comments person.comments if person.comments
    
    json.acceptance_status person.acceptance_status ? person.acceptance_status.name : ''
    json.invite_status person.invitestatus ? person.invitestatus.name : ''
    json.invitation_category person.invitation_category ? person.invitation_category.name : ''
    json.lock_version person.lock_version
    
    if person.pseudonym
        json.pseudonym do |p|
            p.first_name person.pseudonym.first_name 
            p.last_name person.pseudonym.last_name
            p.suffix person.pseudonym.suffix
        end
    end
    
    json.has_survey SurveyService.personAnsweredSurvey( person, 'partsurvey') ? "Y" : "N"

end
