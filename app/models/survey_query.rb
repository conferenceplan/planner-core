
# SurveyQuestion contains 1 or more predicates
# SurveyQuestionPredicate - question operation value

class SurveyQuery < ActiveRecord::Base
  
  # queryPredicates
  has_many :survey_query_predicates, :dependent => :delete_all
  
  accepts_nested_attributes_for :survey_query_predicates, :allow_destroy => true
  
  belongs_to :user
  belongs_to :survey
  
  #
  #
  #
  def survey_query_predicates_attributes=(predicate_attributes)

    # First the new ones
    predicate_attributes.reject {|x| !x['id'].blank? }.each do |predicate| # if there is an id then it is not new
      survey_query_predicates.build(predicate)
    end
    
    # Then the updates and deletes
    survey_query_predicates.reject(&:new_record?).each do |predicate|
      idx = predicate_attributes.find_index { |it| it['id'] == predicate.id }
      if idx
        attributes = predicate_attributes[idx]
        predicate.attributes = attributes
      else
        survey_query_predicates.delete(predicate)
      end
    end
    
  end
    
end
