#
#
#
class MailingJob

  #
  #  
  #
  def perform
    # find all the mailings that have been scheduled
    mailings = Mailing.find :all, :conditions => [ "scheduled = ?", true]
    
    # Go through and process them
    mailings.each do |mailing|
      
      mailing.people.each do |person|
        
        begin
          MailService.sendEmailForMailing(person, mailing)
        rescue => msg
          Delayed::Worker.logger.add(Logger::ERROR, msg)
        end
        
        sleep 20 # For 20 seconds
      end

      # When the mailing is done mark the mailing as completed      
      mailing.scheduled = false
      mailing.save
    end
  end

end
