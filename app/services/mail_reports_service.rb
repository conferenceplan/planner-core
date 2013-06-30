#
#
#
module MailReportsService
  
  #
  # Get the histories order by person (and with optional filters)
  #
  def self.getMailHistory(conditions = {})
    
    # conditions = {:mailing_id => mailingid}
    
    MailHistory.all :joins => [ :person , :mailing ], :conditions => conditions,
        :order => 'people.last_name, people.first_name, mailings.id'
    
  end
  
end
