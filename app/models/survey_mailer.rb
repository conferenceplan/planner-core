class SurveyMailer < ActionMailer::Base

  def thankyou_email(respondent)
    sform = SmerfForm.find_by_id(1)
    
    recipients get_email(respondent)
    cc       "program-form@renovationsf.org"
    from      "no-reply@renovationsf.org"
    subject   "Thank you for completing the questionaire"
    sent_on   Time.now
    content_type "text/html"
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
