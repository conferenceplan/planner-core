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
    if result.survey_respondent && result.survey_respondent.person && result.survey_respondent.person.postal_addresses[0]
        address = city = result.survey_respondent.person.postal_addresses[0].city ? result.survey_respondent.person.postal_addresses[0].city : ''
        address = city + ', ' + result.survey_respondent.person.postal_addresses[0].country if result.survey_respondent.person.postal_addresses[0].country
        json.country address
    else
        json.country ''
    end
    json.filled_at  result.survey_histories.first.filled_at.strftime('%I:%M %p, %d %B %Y')
    json.res_size   result.survey_responses.size.to_s
    
    # if there are multiple responses to same question then concat them i.e. multiple-choice questions
    answers = {}
    result.survey_responses.each do |res|
        if @meta_data && @meta_data[res.survey_question_id]
            if (@meta_data[res.survey_question_id][:question_type] == :multiplechoice) && answers[res.survey_question_id.to_s]
                answers[res.survey_question_id.to_s] += '; ' + res.response
            elsif (@meta_data[res.survey_question_id][:question_type] == :singlechoice)
                ans = SurveyAnswer.find res.survey_answer_id
                answers[res.survey_question_id.to_s] = ans.answer if ans
            elsif (@meta_data[res.survey_question_id][:question_type] == :availability)
                if res.response5
                    answers[res.survey_question_id.to_s] = "I am extremely uncertain when I will be available to be on the Program"
                else
                    answers[res.survey_question_id.to_s] = res.response == '1' ? 'I am available for Program for the complete duration of the convention' : 'I plan to be at the convention.'
                    if res.response == '2'
                        answers[res.survey_question_id.to_s] += ": " + (Time.zone.parse(@site_config.start_date.to_s) + res.response1.to_i.day).strftime('%A, %B %e') + ", " + (res.response2 ? res.response2 : '')
                        answers[res.survey_question_id.to_s] += " => " + (Time.zone.parse(@site_config.start_date.to_s) + res.response3.to_i.day).strftime('%A, %B %e') + ", " + (res.response4 ? res.response4 : '')
                    end
                end
            else
                answers[res.survey_question_id.to_s] = res.response
            end
        end
    end
    answers.each do |k,v|
        json.set! k, v
    end
end
