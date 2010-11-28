class SurveyRespondent < ActiveRecord::Base
  acts_as_authentic do |c| 
    c.validate_email_field = false
  end

  validates_length_of :first_name, :within => 1..40, :too_long => "pick a shorter name", :too_short => "pick a longer name"
  validates_length_of :last_name, :within => 1..40, :too_long => "pick a shorter name", :too_short => "pick a longer name"
  
    
  belongs_to  :person 

  # So we can add tags of various types to the Survey respondents
  acts_as_taggable

end
