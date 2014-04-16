class SurveyQueryPredicate < ActiveRecord::Base
  attr_accessible :lock_version, :operation, :value, :survey_query_id, :survey_question_id
  
  belongs_to :survey_query
  belongs_to :survey_question

end
