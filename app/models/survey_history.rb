class SurveyHistory < ActiveRecord::Base
  attr_accessible :filled_at, :survey_respondent_detail_id, :survey_id, :survey_respondent_detail, :survey
  
  belongs_to :survey_respondent_detail
  belongs_to :survey
  
end
