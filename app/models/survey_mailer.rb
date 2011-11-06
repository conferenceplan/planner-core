class SurveyMailer < ActionMailer::Base

  def thankyou_email(respondent)
    sform = SmerfForm.find_by_id(1)
    
    recipients get_email(respondent)
    cc       "boskone@myconferenceplanning.org"
    from      "no-reply@myconferenceplanning.org"
    subject   "Thank you for completing the questionnaire"
    sent_on   Time.now
    content_type "text/html"
    body      :user => respondent, :url => "http://example.com/login", :responses => get_responses(respondent), 
      :smerfform => sform
  end

  def decline_email(respondent)
    recipients get_email(respondent)
    cc       "boskone@myconferenceplanning.org"
    from      "no-reply@myconferenceplanning.org"
    subject   "Your wish to decline in participating has been recorded"
    sent_on   Time.now
    content_type "text/html"
    body      :user => respondent
  end

  def get_email(respondent)
    return respondent.email
  end

  def get_responses(respondent)
    smerf_forms_surveyrespondent = SmerfFormsSurveyrespondent.find_user_smerf_form(respondent.id, 1)
    
    return smerf_forms_surveyrespondent.responses
  end

end
