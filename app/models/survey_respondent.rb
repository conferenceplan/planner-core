class SurveyRespondent < ActiveRecord::Base
  acts_as_authentic do |c| 
    c.validate_email_field = false
  end

  validates_length_of :first_name, :within => 0..40, :too_long => "pick a shorter name", :too_short => "pick a longer name"
  validates_length_of :last_name, :within => 1..40, :too_long => "pick a shorter name", :too_short => "pick a longer name"
  
    
  belongs_to  :person 
  has_one   :survey_copy_status
  has_enumerated :email_status, :class_name => 'EmailStatus'
  
  has_one :survey_respondent_detail

  # So we can add tags of various types to the Survey respondents
  acts_as_taggable
  
  # add helper methods so we can get the details from the underlying person
  
  def last_name
    return person.last_name
  end

  def first_name
    return person.first_name
  end

  def suffix
    return person.first_name
  end

  def email
    if person.getDefaultEmail()
      return person.getDefaultEmail().email
    else
      return ''  
    end
  end

end
