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
    # if pseudonym is empty, we don't want to insert an empty record
    # so delete attributes from input parameter list so
    # it won't get created
    if (params[:person].has_key?(:pseudonym_attributes))
      if (params[:person][:pseudonym_attributes][:last_name] == "") 
       if (params[:person][:pseudonym_attributes][:first_name] == "")
         if (params[:person][:pseudonym_attributes][:suffix] == "")
           params[:person].delete(:pseudonym_attributes)
         end
       end
      end
    end
    
    @person = Person.new(params[:person])
    
    if (@person.save)
       redirect_to :action => 'index'
    
    else
      render :action => 'new'
    end 
  end

  def update
    
    @person = Person.find(params[:id])
    # if pseudonym is empty, we don't want to insert an empty record
    # so delete attributes from input parameter list so
    # it won't get created. If the pseudonym is getting zeroed
    # out (it existed before and now is not going to exist),
    # we do need to update, so we don't delete the attributes
    if (@person.pseudonym == nil && params[:person].has_key?(:pseudonym_attributes))
      if (params[:person][:pseudonym_attributes][:last_name] == "") 
       if (params[:person][:pseudonym_attributes][:first_name] == "")
         if (params[:person][:pseudonym_attributes][:suffix] == "")
           params[:person].delete(:pseudonym_attributes)
         end
       end
      end
    end
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
  
  def SetInvitePendingToInvited
    
  end
  
  def doSetInvitePendingToInvited
    mailingSelect = params[:exportemail][:mailing_select]
    mailingNumber = params[:exportemail][:mailing_number]
    categorySelect = params[:exportemail][:category_select]
    invitecategory = params[:exportemail][:invitation_category_id]
    if (mailingSelect == nil || categorySelect == nil)
       flash[:error]= "Mailing Select and Category select cannot be empty" 
       render :action => 'SetInvitePendingToInvited'
       return
    end
    selectConditions = {}
    inviteStatus = InviteStatus.find_by_name("Invite Pending")
    selectConditions[:invitestatus_id] = inviteStatus.id
    
    if (categorySelect == "true")
      # category can be empty and we may want to select people with no category
      selectConditions[:invitation_category_id] = nil
      if (invitecategory != "") 
        selectConditions[:invitation_category_id] = invitecategory
      end
    end
    
     if (mailingSelect == "true")
      selectConditions[:mailing_number] = mailingNumber
    end
     @people = Person.find :all, :conditions => selectConditions
     
     @people.each do |person|
       newInviteStatus = InviteStatus.find_by_name("Invited")
       person.invitestatus = newInviteStatus
       person.save
     end
     
  end
  
  def doexportemailxml
    
    mailingSelect = params[:exportemail][:mailing_select]
    mailingNumber = params[:exportemail][:mailing_number]
    acceptanceSelect = params[:exportemail][:acceptance_select]
    acceptanceStatus = params[:exportemail][:acceptance_status_id]
    invitecategory = params[:exportemail][:invitation_category_id]
    categorySelect = params[:exportemail][:category_select]
    invited_index = params[:exportemail][:invitestatus_id]
    inviteStatus = InviteStatus.find(invited_index)
    
    if (inviteStatus.name == "Not Set")
       flash[:error]= "Invite status cannot be Not Set" 
       redirect_to :action => 'exportemailxml'
       return
    end
    
    if (mailingSelect == nil)
       flash[:error]= "Mailing select cannot be empty"
       redirect_to :action => 'exportemailxml'
       return
    end
    if (acceptanceSelect == nil)
       flash[:error]= "Acceptance select cannot be empty"
       redirect_to :action => 'exportemailxml'
       return
    end
    if (categorySelect == nil)
       flash[:error]= "Category select cannot be empty"
       redirect_to :action => 'exportemailxml'
       return
    end
    
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
    
     @people = Person.find :all, :conditions => selectConditions, :order => 'last_name, first_name'
     
     @people.each do |person|
      if (person.survey_respondent == nil)
         # Add the email address to the survey respondent
         possibleEmails = person.email_addresses
         theEmail = nil
         if possibleEmails
           possibleEmails.each do |email| 
             if email.isdefault
               theEmail = email
             else # if the email is empty we want to take the first one (unless there is a default)
               if theEmail == nil
                 theEmail = email
               end
             end
           end
         end
         
         if theEmail == nil
           person.create_survey_respondent(:last_name => person.last_name, 
                                         :first_name => person.first_name,
                                         :key => ('%05d' % rand(1e5)),
                                         :suffix => person.suffix)
         else  
           person.create_survey_respondent(:last_name => person.last_name, 
                                         :first_name => person.first_name,
                                         :key => ('%05d' % rand(1e5)),
                                         :suffix => person.suffix,
                                         :email => theEmail.email)
         end
         person.save
      end
    end

    @people = Person.find :all, :conditions => selectConditions, :order => 'last_name, first_name'
    respond_to do |format|
         format.xml 
         #{
 #            send_data @people.to_xml(:only => [:first_name,:last_name,:email_addresses,:email,:survey_respondent,:key],:include => [:email_addresses,:survey_respondent]), :filename => filename
       #  }
    end
  end
  
 def exportemailxml
   if (@exportXmlError == nil)
    @exportXmlError = ""
   end

 end
end