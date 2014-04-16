class ExcludedPeriodsSurveyMap < ActiveRecord::Base
  attr_accessible :lock_version, :period_type, :period_id, :survey_answer_id
  
  belongs_to :period,  :polymorphic => true, :dependent => :destroy
  belongs_to :survey_answer

end
