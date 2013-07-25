class MappedSurveyQuestion < ActiveRecord::Base
  
  has_many :programme_items, :through => :excluded_items_survey_map
  
  audited

end
