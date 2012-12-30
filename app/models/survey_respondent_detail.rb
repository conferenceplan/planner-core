class SurveyRespondentDetail < ActiveRecord::Base
  
  has_many :survey_responses
  
  # Get the responses for a particular survey
  def getResponses(surveyId)
    return survey_responses.find(:all, :conditions => {:survey_id => surveyId})
  end

  # Get a particular response for a given survey and question  
  def getResponse(surveyId, questionId)
    return survey_responses.first(:all, :conditions => {:survey_id => surveyId, :survey_question_id => questionId})
  end
  
  # return whether or not there are responses for a particular survey
  def hasResponses(surveyId)
    return survey_responses.exists?({:survey_id => surveyId})
  end

end
