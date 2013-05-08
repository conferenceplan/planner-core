class EmailreportsController < PlannerController
  def index
    @pendingCount = SurveyRespondent.count :all, :conditions => [ "email_status_id = ?", EmailStatus[:Pending].id ]
    @failedCount = SurveyRespondent.count :all, :conditions => [ "email_status_id = ?", EmailStatus[:Failed].id ]
    @sentCount = SurveyRespondent.count :all, :conditions => [ "email_status_id = ?", EmailStatus[:Sent].id ]
  end
  
  def failed
    @failed = SurveyRespondent.find :all, :conditions => [ "email_status_id = ?", EmailStatus[:Failed].id ], :include => { :person }
  end

  def sent
    @sent = SurveyRespondent.find :all, :conditions => [ "email_status_id = ?", EmailStatus[:Sent].id ], :include => { :person }
  end

end
