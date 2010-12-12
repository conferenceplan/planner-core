class PeopleController < ApplicationController

  before_filter :require_user

  def destroy
    person = Person.find(params[:id])
    
    person.removeAllAddresses
    person.destroy
    render :layout => 'success'
  end

  def show
    @person = Person.find(params[:id])

    render :layout => 'content'
  end

  def edit
    @person = Person.find(params[:id])
    
    render :layout => 'content'
  end

  def new
    @person = Person.new
  end

  def create
    @person = Person.new(params[:person])
    
    if (@person.save)
       redirect_to :action => 'index'
    
    else
      render :action => 'new'
    end 
  end

  def update
    
    @person = Person.find(params[:id])
    
    if @person.update_attributes(params[:person])
      redirect_to :action => 'show',:id => @person
    else
      render :action => 'edit', :layout => 'content'
    end
  end

  #
  # All the index method does is provide formatting, the actual
  # work for the listing of people is done by the list method
  #
  def index
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  #
  def list
    j = ActiveSupport::JSON
    
    rows = params[:rows]
    @page = params[:page]
    idx = params[:sidx]
    order = params[:sord]
    clause = ""
    fields = Array::new
    
    if (params[:filters])
      queryParams = j.decode(params[:filters])
      if (queryParams)
        clausestr = ""
        queryParams["rules"].each do |subclause|
          if clausestr.length > 0 
            clausestr << ' ' + queryParams["groupOp"] + ' '
          end
          if subclause["op"] == 'ne'
            clausestr << subclause['field'] + ' not like ?'
          else
            clausestr << subclause['field'] + ' like ?'
          end
          fields << subclause['data'] + '%'
          logger.info fields
        end
        clause = [clausestr] | fields
      end
    end
    
    # First we need to know how many records there are in the database
    # Then we get the actual data we want from the DB
    count = Person.count :conditions => clause
    @nbr_pages = (count / rows.to_i).floor + 1
    
    off = (@page.to_i - 1) * rows.to_i
    @people = Person.find :all, :offset => off, :limit => rows,
      :order => idx + " " + order, :conditions => clause
   
    # We return the list of people as an XML structure which the 'table' can us
    # TODO: would it be more efficient to use JSON instead?
    respond_to do |format|
      format.xml
    end
  end
  
  def doexportemailxml
    filename = params[:exportemail][:filename]
    mailingSelect = params[:exportemail][:mailing_select]
    mailingNumber = params[:exportemail][:mailing_number]
    acceptanceSelect = params[:exportemail][:acceptance_select]
    acceptanceStatus = params[:exportemail][:acceptance_status_id]
    invitecategory = params[:exportemail][:invitation_category_id]
    categorySelect = params[:exportemail][:category_select]
    invited_index = params[:exportemail][:invitestatus_id]
    selectConditions = {}
    selectConditions[:invitestatus_id] = invited_index
    
    
    if (categorySelect == "true")
      # category can be empty and we may want to select people with no category
      selectConditions[:invitation_category_id] = nil
      if (invitecategory != "") 
        selectConditions[:invitation_category_id] = invitecategory
      end
    end
    
    if (acceptanceSelect == "true")
        selectConditions[:acceptance_status_id] = acceptanceStatus
    end
    
    if (mailingSelect == "true")
      selectConditions[:mailing_number] = mailingNumber
    end
    
    @people = Person.find :all, :conditions => selectConditions
    respond_to do |format|
         format.xml {
             send_data @people.to_xml(:only => [:first_name,:last_name,:email_addresses,:email],:include => :email_addresses), :filename => filename
         }
    end
  end
  
 def exportemailxml

 end
end