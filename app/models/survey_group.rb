class SurveyGroup < ActiveRecord::Base
  
  belongs_to  :survey

  has_many :survey_questions, :dependent => :delete
 
end
