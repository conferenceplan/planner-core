
# SurveyQuestion contains 1 or more conditions
# SurveyQuestionCondition - question operation value

class SurveyQuery < ActiveRecord::Base
  
  has_many :survey_query_conditions
  
  # List of anded statements
  
  # List of or'd statements

end
