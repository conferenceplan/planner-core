#
#
#
module MailReportsService
  
  #
  # Get the histories order by person (and with optional filters)
  #
  def self.getMailHistory(conditions = {}, page=nil, per_page=nil)
    
    count = MailHistory.count :joins => [ :person , :mailing ], :conditions => conditions

    if per_page
      nbr_pages = (count / per_page.to_i).floor
      nbr_pages += 1 if count % per_page.to_i > 0
    else
      nbr_pages = 1
    end
    offset = (page.to_i - 1) * per_page.to_i
    
    MailHistory.all :joins => [ :person , :mailing ], :conditions => conditions,
        :order => 'people.last_name, people.first_name, mailings.id',
        :offset => offset, :limit => per_page
    
  end
  
  def self.getNumberOfMailHistories(conditions = {})
    MailHistory.count :joins => [ :person , :mailing ], :conditions => conditions
  end
  
end
