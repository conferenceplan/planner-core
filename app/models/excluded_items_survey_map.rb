class ExcludedItemsSurveyMap < ActiveRecord::Base
  belongs_to :programme_item
  belongs_to :survey_answer
  
  acts_as_audited :parent => :programme_item

end
