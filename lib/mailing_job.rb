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
        mailHistory.date_sent = Date.today
        mailHistory.person = person
        mailHistory.mailing = mailing
        
        begin
          # Add the args to the mailing
          SurveyMailer.deliver_mailingEmail(person, mailing, mailHistory, {
            :person => person,
            :assignments => getProgramItems(person)
          })
          
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
  
  def getProgramItems(person)
    assignments = ProgrammeItemAssignment.all(
        :conditions => ['(programme_item_assignments.person_id = ?) AND (programme_item_assignments.role_id in (?))', 
            person.id, 
            [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id,PersonItemRole['Invisible'].id]],
            :include => {:programmeItem => [{:programme_item_assignments => {:person => [:pseudonym, :email_addresses]}}, :equipment_types, {:room => :venue}, :time_slot]},
            :order => "time_slots.start asc"
      )

    return assignments
  end

  
end