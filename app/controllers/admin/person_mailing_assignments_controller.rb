class Admin::PersonMailingAssignmentsController < PlannerController
  def index
    # Return a list of the person mailing assignments
    # pass in a paramter that specifies the mailing so that we can filter
    mailing_id = params[:mailing_id]
    mailingAssignments = nil
    
    if mailing_id
      mailingAssignments = PersonMailingAssignment.find :all, :conditions => {:mailing_id => mailing_id}, :include => {:person => :pseudonym}, :order => "people.last_name asc"
    else  
      mailingAssignments = PersonMailingAssignment.find :all, :include => {:person => :pseudonym}, :order => "people.last_name asc"
    end
    
    ActiveRecord::Base.include_root_in_json = false # hack for now

    render :json => mailingAssignments.to_json( :include => { :person => {:include => :pseudonym}, :mailing => {}} ), :callback => params[:callback]
  end
  
  def new
    # NOTE: we need a new method for the create to work...
  end

  def create
    # Create an instance of a mailing assigment, given a person and mailing
    # Input person id, mailing id
    # make sure we do not have a dup
    
    mailingAssignment = PersonMailingAssignment.new
    
    mailingAssignment.person_id = params[:person][:id]
    mailingAssignment.mailing_id = params[:mailing][:id]
    
    mailingAssignment.save!
    
    ActiveRecord::Base.include_root_in_json = false # hack for now

    render :json => mailingAssignment, :callback => params[:callback]
  end

  def update
    # Update the mailing assigment, given a person and mailing
    mailingAssignment = PersonMailingAssignment.find(params[:id])

    mailingAssignment.person_id = params[:person][:id]
    mailingAssignment.mailing_id = params[:mailing][:id]
    
    mailingAssignment.save!
    
    ActiveRecord::Base.include_root_in_json = false # hack for now

    render :json => mailingAssignment, :callback => params[:callback]
  end

  def destroy
    # Destroy the mailing assignment
    mailingAssignment = PersonMailingAssignment.find(params[:id])
    
    mailingAssignment.destroy
    #redirect_to :action => 'index'
    render :layout => 'success' # TODO - check
  end

end
