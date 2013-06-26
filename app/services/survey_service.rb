#
#
#
class SurveyService

  #
  # Get all the people who said that they do not want to share their email with other participants
  #  
  def self.findPeopleWithDoNotShareEmail
    
    Person.all :joins => {:survey_respondent => {:survey_respondent_detail => {:survey_responses => {:survey_question => :survey_answers}}}},
            :conditions => ["survey_answers.answertype_id = ? AND survey_answers.answer = survey_responses.response", AnswerType['DoNotShareEmail'].id]
    
  end

end
