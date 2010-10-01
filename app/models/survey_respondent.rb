class SurveyRespondent < ActiveRecord::Base
  acts_as_authentic # TODO - test to see if this is needed...

  belongs_to  :person 
end
