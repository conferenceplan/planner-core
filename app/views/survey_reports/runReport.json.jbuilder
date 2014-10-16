json.totalpages 1
json.currpage 1
json.totalrecords @result.size
json.show_country @show_country

json.userdata @meta_data

json.rowdata @result.collect do |result|
    json.first_name result.first_name
    json.last_name  result.last_name
    json.suffix     result.suffix
    json.email      result.email
    json.country    (result.survey_respondent.person.postal_addresses[0].city ? result.survey_respondent.person.postal_addresses[0].city + ', ' : '')  + result.survey_respondent.person.postal_addresses[0].country
    json.filled_at  result.created_at.strftime('%I:%M %p, %d %B %Y')
    json.res_size   result.survey_responses.size.to_s
    
    # TODO - if there are multiple responses to same question then concat them i.e. multiple-choice questions
    result.survey_responses.each do |res|
        json.set! res.survey_question_id.to_s, res.response
    end
end
