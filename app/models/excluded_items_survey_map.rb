class ExcludedItemsSurveyMap < ActiveRecord::Base
  belongs_to :programme_item
  belongs_to :mapped_survey_question
  
  acts_as_audited :parent => :programme_item

end
