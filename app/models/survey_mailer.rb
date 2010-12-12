class SurveyMailer < ActionMailer::Base

  def thankyou_email(respondent)
    recipients get_email(respondent)
    from      "no-reply@renovationsf.org"
    subject   "Thank you for completing the survey"
    sent_on   Time.now
    body      :user => respondent, :url => "http://example.com/login"
  end

  def get_email(respondent)
    smerf_forms_surveyrespondent = SmerfFormsSurveyrespondent.find_user_smerf_form(respondent.id, 1)
    
    return smerf_forms_surveyrespondent.responses['g4q6']
  end

end
