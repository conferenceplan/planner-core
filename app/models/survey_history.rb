class SurveyHistory < ActiveRecord::Base
  # attr_accessible :title, :body
  
  belongs_to :survey_respondent_detail
  belongs_to :survey
  
end
