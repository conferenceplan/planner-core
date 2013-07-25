#
#
#
class MailingJob
  
  def perform
    # find all the mailings that have been scheduled
    mailings = Mailing.find :all, :conditions => [ "scheduled = ?", true]
    
    # Go through and process them
    mailings.each do |mailing|

      mailing.people.each do |person|
        
        pma = PersonMailingAssignment.find :first, :conditions => {:person_id => person, :mailing_id => mailing}
        
        mailHistory = MailHistory.new()
        mailHistory.person_mailing_assignment = pma

        mailHistory.testrun = mailing.testrun
        mailHistory.email = person.getDefaultEmail
        mailHistory.date_sent = DateTime.now
        mailHistory.person = person
        mailHistory.mailing = mailing
        
        begin
          # Add the args to the mailing
          SurveyMailer.mailingEmail(person, mailing, mailHistory, {
            :person => person,
            :assignments => ProgramItemsService.findProgramItemsForPerson(person)
          }).deliver
          
          # set the status
          mailHistory.email_status = EmailStatus[:Sent]
        rescue => msg
          mailHistory.email_status = EmailStatus[:Failed]
          mailHistory.content = msg
          Delayed::Worker.logger.add(Logger::ERROR, msg)
        end
        
        mailHistory.save
        
        #sleep 20 # For 20 seconds
      end

      mailing.scheduled = false
      mailing.save
      sleep 20 # For 20 seconds

    end
  end
  
end