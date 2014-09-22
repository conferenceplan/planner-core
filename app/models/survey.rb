class Survey < ActiveRecord::Base
  attr_accessible :lock_version, :name, :welcome, :thank_you, :alias, :submit_string, :header_image, :use_captcha, :public, :authenticate,
                  :declined_msg, :authenticate_msg, :accept_status_id, :decline_status_id
  
  # Survey contains a series of groups, groups contain a series of questions
  has_many :survey_groups, :dependent => :destroy, :order => 'sort_order asc'
  
  has_enumerated :accept_status, :class_name => 'AcceptanceStatus' # the status that a person's acceptance transistions too completing syrvey
  has_enumerated :decline_status, :class_name => 'AcceptanceStatus' # the status that a person's acceptance transistions too when declining the survey

  has_many :survey_responses
  
  before_destroy :check_for_use, :check_if_published
  
  def getAllQuestions
    res = Array.new
    
    # get the groups and from them get all the questions
    survey_groups.each do |grp|
       res.concat(grp.survey_questions)
    end
    
    return res
  end

private

  def check_for_use
    if survey_responses.any?
      raise "can not delete a survey that has responses in the system"
    end
  end
  
  def check_if_published
    if public
      raise "can not delete a survey that is public"
    end
  end
  
end
