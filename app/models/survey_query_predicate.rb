class SurveyQueryPredicate < ActiveRecord::Base
  
    belongs_to :survey_query
    belongs_to :survey_question

end
