class SurveyRespondentDetail < ActiveRecord::Base
  
  has_many :survey_responses

  # validates_length_of :first_name, :within => 1..60, :too_long => "pick a shorter first name", :too_short => "pick a longer first name"
  # validates_length_of :last_name, :within => 1..60, :too_long => "pick a shorter last name", :too_short => "pick a longer last name"  
  # validates_length_of :email, :within => 1..100, :too_long => "pick a shorter email address", :too_short => "pick a longer email address"  

end
