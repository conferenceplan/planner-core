json.array! @questions do |question|

    json.id             question.id
    json.lock_version   question.lock_version
    json.question        question.question
    json.question_type         question.question_type
    json.mandatory         question.mandatory
    json.answer_type         question.answer_type
    json.isbio         question.isbio
    json.survey_group         question.survey_group
    json.sort_order         question.sort_order
    json.survey_answers         question.survey_answers

end

