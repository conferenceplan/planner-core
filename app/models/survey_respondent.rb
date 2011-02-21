class SurveyRespondent < ActiveRecord::Base
  acts_as_authentic do |c| 
    c.validate_email_field = false
  end

  validates_length_of :first_name, :within => 0..40, :too_long => "pick a shorter name", :too_short => "pick a longer name"
  validates_length_of :last_name, :within => 1..40, :too_long => "pick a shorter name", :too_short => "pick a longer name"
  
    
  belongs_to  :person 
  has_one   :survey_copy_status

  # So we can add tags of various types to the Survey respondents
  acts_as_taggable

end
