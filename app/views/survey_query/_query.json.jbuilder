
json.id             query.id
json.lock_version   query.lock_version
json.name           query.name
json.user_id        query.user_id
json.shared         query.shared

if (!(defined? terse)) || ((defined? terse) && !terse)
    json.operation      query.operation
    json.survey_id      query.survey_id
    json.survey_name    query.survey.name
    
    json.survey_query_predicates do
        json.array! query.survey_query_predicates do |p|
            json.id                 p.id
            json.lock_version       p.lock_version
            json.operation          p.operation
            json.survey_query_id    p.survey_query_id
            json.survey_question_id p.survey_question_id
            json.survey_question_name   p.survey_question.question
            json.value              p.value
        end
    end
    
    
end
