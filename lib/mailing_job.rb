#
#
#
require 'job_utils'

class MailingJob

  include JobUtils
  
  attr_accessor :mailing_id
  attr_accessor :base_url

  #
  #
  #  
  def perform
    cfg = getSiteConfig
    zone = cfg ? cfg.time_zone : Time.zone
    Time.use_zone(zone) do
      # find all the mailings that have been scheduled
      mailing = Mailing.find mailing_id #:all, :conditions => [ "scheduled = ?", true]
      index = mailing.last_person_idx
      
      if mailing.scheduled # Check just in case this is a dup
        mailing.people.each_with_index do |person, idx|
          if ((index == -1) || (idx > index))
            begin
              MailService.sendEmailForMailing(person, mailing, base_url)
              
              # note the last person processes so we can continue from there if job stopped and restarted
              mailing.last_person_idx = idx # use a counter
              mailing.save
            rescue => msg
              # Delayed::Worker.logger.add(Logger::ERROR, msg) if Delayed::Worker.logger
              Sidekiq::Logging.logger.error msg if Sidekiq::Logging.logger
              raise msg
            end
            sleep 0.5 # For 0.5 second between sending emails
          end
        end
    
        # When the mailing is done mark the mailing as completed      
        mailing.scheduled = false
        mailing.save
      end
    end
  end

end
