
json.id             question.id
json.lock_version   question.lock_version
json.title          question.title          # ?? USED ???
json.sort_order     question.sort_order
json.tags_label     question.tags_label
json.isbio          question.isbio

json.mandatory      question.mandatory
json.question_type  question.question_type
json.question       question.question
json.answer_type    question.answer_type

#json.question1      question.question1
#json.answer1_type   question.answer1_type
#json.question2      question.question2
#json.answer2_type   question.answer2_type
#json.question3      question.question3
#json.answer3_type   question.answer3_type
#json.question4      question.question4
#json.answer4_type   question.answer4_type
#json.question5      question.question5
#json.answer5_type   question.answer5_type
#json.question6      question.question6
#json.answer6_type   question.answer6_type

# TODO - we want these to be provided by other utlities ???
json.survey_format   question.survey_format if question.survey_format
json.survey_answers  question.survey_answers if question.survey_answers
