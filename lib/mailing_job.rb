#
#
#
class MailingJob
  
  attr_accessor :mailing_id

  #
  #
  #  
  def perform
    cfg = SiteConfig.find :first
    zone = cfg ? cfg.time_zone : Time.zone
    Time.use_zone(zone) do
      # find all the mailings that have been scheduled
      mailing = Mailing.find mailing_id #:all, :conditions => [ "scheduled = ?", true]
      
      if mailing.scheduled # Check just in case this is a dup
        mailing.people.each do |person|
          begin
            MailService.sendEmailForMailing(person, mailing)
          rescue => msg
            # Delayed::Worker.logger.add(Logger::ERROR, msg) if Delayed::Worker.logger
            Sidekiq::Logging.logger.error msg if Sidekiq::Logging.logger
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
