
json.totalpages 1
json.currpage 1
    
json.rowdata @editedBios do |e|

    json.name               e.person.getFullPublicationName
    json.bio                e.bio
    json.website            e.website ? e.website : ''
    json.twitterinfo        e.twitterinfo ? e.twitterinfo : ''
    json.othersocialmedia   e.othersocialmedia ? e.othersocialmedia : ''
    json.photourl           e.photourl ? e.photourl : ''
    json.facebook           e.facebook ? e.facebook : ''
    
end
