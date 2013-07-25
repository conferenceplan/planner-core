class ExcludedItemsSurveyMap < ActiveRecord::Base
  belongs_to :programme_item
  belongs_to :survey_answer
  
  audited :associated_with => :programme_item, :allow_mass_assignment => true

end
