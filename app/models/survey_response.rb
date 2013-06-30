class SurveyResponse < ActiveRecord::Base
  
  belongs_to :survey_respondent_detail
  belongs_to :survey_question
  
  belongs_to :survey
  
end
