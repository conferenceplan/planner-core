#
#
#
class Mail::MailHistoryController < PlannerController
  
  #
  #
  #
  def index
    conditions = {}
    filters = {:person => params[:person], :mailing => params[:mailing]}
    
    # Get the histories for a specific mailing
    filters.merge! :mailing_id => params[:mailing_id] if params[:mailing_id]
    
    # Get the histories for a specific person
    filters.merge! :person_id => params[:person_id] if params[:person_id]
    
    history = MailReportsService.getMailHistory conditions, 
                  { :page => params[:page], :per_page => params[:per_page],
                    :sort_by => params[:sort_by], :order => params[:order],
                    :filters => filters }

    # And return the results as a JSON collection
    ActiveRecord::Base.include_root_in_json = false
    render :json => history.to_json( :include => { :person => {:include => :pseudonym}, :mailing => {}} ), :callback => params[:callback]
  end

  #
  #
  #  
  def count
    conditions = {}
    filters = {:person => params[:person], :mailing => params[:mailing]}
    
    filters.merge! :mailing_id => params[:mailing_id] if params[:mailing_id]
    filters.merge! :person_id => params[:person_id] if params[:person_id]
    
    count = MailReportsService.getNumberOfMailHistories conditions, { :filters => filters }
    
    ActiveRecord::Base.include_root_in_json = false
    render :json => count
  end

end
