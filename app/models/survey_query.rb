
class SurveyQuery < ActiveRecord::Base
  attr_accessible :lock_version, :name, :operation, :shared, :date_order, :show_country, :survey_id, :user_id
  
  # queryPredicates
  has_many :survey_query_predicates, :dependent => :delete_all
  
  accepts_nested_attributes_for :survey_query_predicates, :allow_destroy => true
  
  belongs_to :user
  belongs_to :survey
  
  def update_predicates(new_predicates)

    updates = Hash[ new_predicates.map { |a| (a[:id] ? [a[:id], a] : nil) }.compact ]
    newPredicates = new_predicates.collect { |a| (a[:id] ? nil : a) }.compact

    survey_query_predicates.each do |predicate|
      if updates[predicate.id]
        predicate.update_attributes( updates[predicate.id] )
      else
        # delete it and remove it from the collection
        candidate = survey_query_predicates.delete(predicate)
      end
    end
    
    # now create the new ones
    newPredicates.each do |predicate|
      survey_query_predicates << SurveyQueryPredicate.new(predicate)
    end
    
  end
  
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
