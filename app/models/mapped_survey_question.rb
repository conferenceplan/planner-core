class MappedSurveyQuestion < ActiveRecord::Base
  attr_accessible :lock_version, :question, :code, :name
  
  has_many :programme_items, :through => :excluded_items_survey_map
  
  audited

end
