#
#
#
class EmailJob
  def perform
    # Go through the survey respondents and generate emails
    
    # Get the survey respondents for which an email needs to be sent
    respondents = SurveyRespondent.find :all, :conditions => [ "email_status_id = ?", EmailStatus[:Pending].id ]
    
    respondents.each do |respondent|
      # Send the email
      begin
        SurveyMailer.deliver_email(respondent.email, MailUse[:Invite], nil, { 
          :user => respondent,
          :key => respondent.key
           }).deliver # send out invite email
        # Mark the status
        respondent.email_status = EmailStatus[:Sent]
      rescue => msg
        # Mark the status as failed
        respondent.email_status = EmailStatus[:Failed]
        Delayed::Worker.logger.add(Logger::ERROR, msg)
      end

      respondent.save
      sleep 20 # For 20 seconds
    end
  end
end