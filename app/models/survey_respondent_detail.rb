class SurveyRespondentDetail < ActiveRecord::Base
  attr_accessible :lock_version, :first_name, :last_name, :suffix, :email, :survey_respondent_id, :survey_id, :prefix, 
                  :company, :job_title
  
  has_many :survey_responses, :dependent => :destroy
  belongs_to  :survey_respondent 
  has_many :survey_histories, :dependent => :destroy

  # Get the responses for a particular survey
  def getResponses(surveyId)
    return survey_responses.where({:survey_id => surveyId})
  end

  def getHistories(surveyId)
    return survey_histories.where({:survey_id => surveyId})
  end

  # Get a particular response for a given survey and question  
  def getResponse(surveyId, questionId)
    return survey_responses.where({:survey_id => surveyId, :survey_question_id => questionId}).first
  end
  
  def getResponsesForQuestion(surveyId, questionId) # TODO - optimize usage
    return survey_responses.where({:survey_id => surveyId, :survey_question_id => questionId})
  end
  
  # return whether or not there are responses for a particular survey
  def hasResponses(surveyId)
    return survey_responses.exists?({:survey_id => surveyId})
  end

  def hasResponsesForQuestion(surveyId, questionId) # TODO - optimize usage
    return survey_responses.exists?({:survey_id => surveyId, :survey_question_id => questionId})
  end
  
  def getFullName
      return [self.prefix, self.first_name,self.last_name,self.suffix].compact.join(' ').strip
  end

end
