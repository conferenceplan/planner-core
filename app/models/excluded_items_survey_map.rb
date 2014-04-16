class ExcludedItemsSurveyMap < ActiveRecord::Base
  attr_accessible :lock_version, :programme_item_id, :survey_answer_id
  
  belongs_to :programme_item
  belongs_to :survey_answer
  
  audited :associated_with => :programme_item, :allow_mass_assignment => true

end
