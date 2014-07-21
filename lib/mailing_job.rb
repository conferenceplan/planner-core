#
#
#
class MailingJob

  #
  #
  #  
  def perform
    cfg = SiteConfig.find :first
    zone = cfg ? cfg.time_zone : Time.zone
    Time.use_zone(zone) do
      # find all the mailings that have been scheduled
      mailings = Mailing.find :all, :conditions => [ "scheduled = ?", true]
      
      # Go through and process them
      mailings.each do |mailing|
        
        mailing.people.each do |person|
          
          begin
  
            MailService.sendEmailForMailing(person, mailing)
          rescue => msg
            Delayed::Worker.logger.add(Logger::ERROR, msg) if Delayed::Worker.logger
            logger.error msg if !Delayed::Worker.logger
          end
          
          sleep 20 # For 20 seconds
        end
  
        # When the mailing is done mark the mailing as completed      
        mailing.scheduled = false
        mailing.save
      end
    end
  end

end
