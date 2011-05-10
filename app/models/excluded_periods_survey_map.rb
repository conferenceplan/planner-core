class ExcludedPeriodsSurveyMap < ActiveRecord::Base
  
  belongs_to :period,  :polymorphic => true

end
