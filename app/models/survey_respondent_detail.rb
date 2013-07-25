class SurveyRespondentDetail < ActiveRecord::Base
  
  has_many :survey_responses
  belongs_to  :survey_respondent 

  attr_accessible :first_name, :last_name, :suffix, :email
  
  # Get the responses for a particular survey
  def getResponses(surveyId)
    return survey_responses.find(:all, :conditions => {:survey_id => surveyId})
  end

  # Get a particular response for a given survey and question  
  def getResponse(surveyId, questionId)
    return survey_responses.first(:conditions => {:survey_id => surveyId, :survey_question_id => questionId})
  end
  
  def getResponsesForQuestion(surveyId, questionId) # TODO - optimize usage
    return survey_responses.find(:all, :conditions => {:survey_id => surveyId, :survey_question_id => questionId})
  end
  
  # return whether or not there are responses for a particular survey
  def hasResponses(surveyId)
    return survey_responses.exists?({:survey_id => surveyId})
  end

  def hasResponsesForQuestion(surveyId, questionId) # TODO - optimize usage
    return survey_responses.exists?({:survey_id => surveyId, :survey_question_id => questionId})
  end

end
