class Mail::MailHistoryController < PlannerController
  
  def index
    conditions = {}
    page = params[:page]
    per_page = params[:per_page]
    
    # Get the histories for a specific mailing
    if params[:mailing_id]
      conditions.merge! :mailing_id => params[:mailing_id]
    end
    
    # Get the histories for a specific person
    if params[:person_id]
      conditions.merge! :person_id => params[:person_id]
    end
    
    history = MailReportsService.getMailHistory conditions, page, per_page

    # And return the results as a JSON collection
    ActiveRecord::Base.include_root_in_json = false
    render :json => history.to_json( :include => { :person => {:include => :pseudonym}, :mailing => {}} ), :callback => params[:callback]

  end
  
  def count
    conditions = {}
    
    if params[:mailing_id]
      conditions.merge! :mailing_id => params[:mailing_id]
    end
    
    # Get the histories for a specific person
    if params[:person_id]
      conditions.merge! :person_id => params[:person_id]
    end
    
    count = MailReportsService.getNumberOfMailHistories conditions
    
    ActiveRecord::Base.include_root_in_json = false
    render :json => count
  end

end
