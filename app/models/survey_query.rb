
# SurveyQuestion contains 1 or more predicates
# SurveyQuestionPredicate - question operation value

class SurveyQuery < ActiveRecord::Base
  
  # queryPredicates
  has_many :survey_query_predicates, :dependent => :delete_all
  
  accepts_nested_attributes_for :survey_query_predicates, :allow_destroy => true
  
  belongs_to :user
  
end
