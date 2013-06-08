class ExcludedPeriodsSurveyMap < ActiveRecord::Base
  
  belongs_to :period,  :polymorphic => true, :dependent => :destroy
  belongs_to :survey_answer

end
