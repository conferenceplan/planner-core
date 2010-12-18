class SurveyMailer < ActionMailer::Base

  def thankyou_email(respondent)
    sform = SmerfForm.find_by_id(1)
    
    recipients get_email(respondent)
    bcc       "programform@renovationsf.org"
    from      "no-reply@renovationsf.org"
    subject   "Thank you for completing the survey"
    sent_on   Time.now
    body      :user => respondent, :url => "http://example.com/login", :responses => get_responses(respondent), 
      :smerfform => sform
  end

  def get_email(respondent)
    smerf_forms_surveyrespondent = SmerfFormsSurveyrespondent.find_user_smerf_form(respondent.id, 1)
    
    return smerf_forms_surveyrespondent.responses['g4q6']
  end

  def get_responses(respondent)
    smerf_forms_surveyrespondent = SmerfFormsSurveyrespondent.find_user_smerf_form(respondent.id, 1)
    
    return smerf_forms_surveyrespondent.responses
  end

end
