json.totalpages @nbr_pages
json.currpage @page
json.totalrecords @count
json.currentSelection @currentId if @currentId
    
json.rowdata @people do |person|

    
    json.id person.id
    json.set! "person[first_name]", person.first_name
    json.set! "person[last_name]", person.last_name
    json.set! "person[suffix]", person.suffix
    json.set! "person[comments]", person.comments if person.comments
    
    json.set! "person[acceptance_status_id]", person.acceptance_status ? person.acceptance_status.name : ''
    json.set! "person[invitestatus_id]", person.invitestatus ? person.invitestatus.name : ''
    json.set! "person[invitation_category_id]", person.invitation_category ? person.invitation_category.name : ''
    json.set! "person[lock_version]", person.lock_version
    
    if person.pseudonym
            json.set! "person[pseudonym_attributes][first_name]", person.pseudonym.first_name 
            json.set! "person[pseudonym_attributes][last_name]", person.pseudonym.last_name
            json.set! "person[pseudonym_attributes][suffix]", person.pseudonym.suffix
    end
    
    if @includeMailings
        json.set! "person[mailings]", person.mailings
    end
    
    json.set! "person[has_survey]", SurveyService.personAnsweredSurvey( person, 'partsurvey') ? "Y" : "N"
    
    json.set! "default_email", person.getDefaultEmail

end
