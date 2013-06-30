class Mail::MailHistoryController < PlannerController
  
  def index
    conditions = {}
    
    # Get the histories for a specific mailing
    if params[:mailing_id]
      conditions.merge! :mailing_id => params[:mailing_id]
    end
    
    # Get the histories for a specific person
    if params[:person_id]
      conditions.merge! :person_id => params[:person_id]
    end
    
    history = MailReportsService.getMailHistory conditions

    # And return the results as a JSON collection
    ActiveRecord::Base.include_root_in_json = false
    render :json => history.to_json( :include => { :person => {:include => :pseudonym}, :mailing => {}} ), :callback => params[:callback]

  end

end
