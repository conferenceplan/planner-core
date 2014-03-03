require 'survey'
require 'survey_respondent_detail'
require 'survey_history'

class PopulateSurveyHistory < ActiveRecord::Migration
  
  # For each survey filled make sure that the survey history table has an entry (where possible)
  def up
    # select the survey that is part survey
    survey = Survey.find_by_alias('partsurvey')
    
    if survey
      # select each survey respondent detail that has a respondent id
      respondentDetails = SurveyRespondentDetail.where "survey_respondent_id is not null"
      
      respondentDetails.each do |details|
        
        hist = SurveyHistory.new :survey_respondent_detail => details, :survey => survey, :filled_at => details.updated_at
        hist.save!
        
      end
    end
    
  end

  def down
  end
end
