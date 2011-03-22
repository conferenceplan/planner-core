class PeopleController < PlannerController

  def destroy
    person = Person.find(params[:id])
    
    person.removeAllAddresses
    person.destroy
    render :layout => 'success'
  end

  def show
    @person = Person.find(params[:id])
    comp = params[:comp]
    
    if comp
      @postalAddresses = @person.postal_addresses
      @emailAddresses = @person.email_addresses
      @phoneNumbers= @person.phone_numbers
      render :comphrensive, :layout => 'content'
    else  
      render :layout => 'content'
    end
  end

  def edit
    @person = Person.find(params[:id])
    
    render :layout => 'content'
  end

  def new
    @person = Person.new
    @person.mailing_number = 0
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
      render :action => 'show', :layout => 'content'
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

    @editable = false
    if @person.update_attributes(params[:person])
      render :action => 'show', :layout => 'content'
#      render :action => 'edit', :layout => 'content', :locals => { :editable => editable}
    else
      render :action => 'show', :layout => 'content'
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
    rows = params[:rows]
    @page = params[:page]
    idx = params[:sidx]
    order = params[:sord]
    context = params[:context]
    nameSearch = params[:namesearch]
    
    clause = createWhereClause(params[:filters], 
    ['invitestatus_id', 'invitation_category_id', 'acceptance_status_id'],
    ['invitestatus_id', 'invitation_category_id', 'acceptance_status_id', 'mailing_number'])
    
    # add the name search for last of first etc
    if nameSearch && ! nameSearch.empty? #
      clause = addClause(clause,'people.last_name like ? OR pseudonyms.last_name like ?','%' + nameSearch + '%')
      clause << '%' + nameSearch + '%'
    end

    # if the where clause contains pseudonyms. then we need to add the join
    args = { :conditions => clause }
    if nameSearch && ! nameSearch.empty?
      args.merge!( :joins => 'LEFT JOIN pseudonyms ON pseudonyms.person_id = people.id' )
    else
      if clause != nil && clause[0].index('pseudonyms.') != nil
        args.merge!( :joins => :pseudonym )
      end
    end
    
    tagquery = ""
    if context
      if context.class == HashWithIndifferentAccess
        context.each do |key, ctx|
          tagquery += ".tagged_with('" + params[:tags][key] + "', :on => '" + ctx + "', :any => true)"
        end
      else
        tagquery += ".tagged_with('" + params[:tags] + "', :on => '" + context + "', :op => true)"
      end
    end
    
    # First we need to know how many records there are in the database
    # Then we get the actual data we want from the DB
    if tagquery.empty?
      @count = Person.count args
    else
      @count = eval "Person#{tagquery}.count :all, " + args.inspect
    end
    @nbr_pages = (@count / rows.to_i).floor
    @nbr_pages += 1 if @count % rows.to_i > 0
    
    # now we get the actual data
    offset = (@page.to_i - 1) * rows.to_i
    args.merge!(:offset => offset, :limit => rows, :order => idx + " " + order)
    
    if tagquery.empty?
      @people = Person.find :all, args
    else
      @people = eval "Person#{tagquery}.find :all, " + args.inspect
    end
    
    # We return the list of people as an XML structure which the 'table' can use
    respond_to do |format|
      format.html { render :layout => 'content' } # list.html.erb
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
         
         # make sure the survey key is unique
         survey_respondent = nil
         newKeyValue = 0
         begin
           newKeyValue = ('%05d' % rand(1e5))
           survey_respondent = SurveyRespondent.find_by_key(newKeyValue)
         end until survey_respondent == nil
         
         if theEmail == nil
           person.create_survey_respondent(:last_name => person.last_name, 
                                         :first_name => person.first_name,
                                         :key => newKeyValue,
                                         :suffix => person.suffix,
                                         :submitted_survey => false)
         else  
           person.create_survey_respondent(:last_name => person.last_name, 
                                         :first_name => person.first_name,
                                         :key => newKeyValue,
                                         :suffix => person.suffix,
                                         :email => theEmail.email,
                                         :submitted_survey => false)
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
  
  def doReportInviteStatus
    
    acceptanceSelect = params[:reportInviteStatus][:acceptance_select]
    acceptanceStatus = params[:reportInviteStatus][:acceptance_status_id]
    invitecategories = params[:reportInviteStatus][:invitation_category_id]
    invited_index = params[:reportInviteStatus][:invitestatus_id]
    inviteStatus = InviteStatus.find(invited_index)
    
    if (inviteStatus.name == "Not Set")
       flash[:error]= "Invite status cannot be Not Set" 
       redirect_to :action => 'ReportInviteStatus'
       return
    end
    
    if (acceptanceSelect == nil)
       flash[:error]= "Acceptance select cannot be empty"
       redirect_to :action => 'ReportInviteStatus'
       return
    end
    if (invitecategories == nil)
       flash[:error]= "Invitation category cannot be empty"
       redirect_to :action => 'ReportInviteStatus'
       return
    end
 
    @searchDescription = "Invitation Status = " + inviteStatus.name
    selectConditions = "invitestatus_id = "+invited_index.to_s
    if (invitecategories.length != 0)
      selectConditions = selectConditions + " AND "
      @searchDescription = @searchDescription + " and "
    end
    addOr = "("
    invitecategories.each do |invitecategory| 
        inviteCategoryEntry = InvitationCategory.find(invitecategory)
        @searchDescription = @searchDescription + " Invitation Category = " + inviteCategoryEntry.name
        selectConditions = selectConditions + addOr + "invitation_category_id = " + invitecategory.to_s
        addOr = " OR "
    end
    selectConditions = selectConditions + ")"
    
    if (acceptanceSelect == "true")
        selectConditions = selectConditions + " AND "
        selectConditions = selectConditions + "acceptance_status_id = "+ acceptanceStatus.to_s
        acceptanceEntry = AcceptanceStatus.find(acceptanceStatus)

        @searchDescription = @searchDescription + " and Acceptance status = " + acceptanceEntry.name
    end

    @people = Person.find :all, :conditions => selectConditions, :order => 'last_name, first_name'
    @nosurveypeople = []
    surveypeople = []
    @people.each do |person|
      @accepted = AcceptanceStatus.find_by_name("Accepted")        
      if (person.acceptance_status_id == @accepted.id)
        if (person.hasSurvey? == false)
          @nosurveypeople << person
        else
          surveypeople << person
        end
      else
        surveypeople << person
      end
    end
    @people = surveypeople
  end
  
  def exportbiolist
    accepted = AcceptanceStatus.find_by_name("Accepted")        
    invitestatus = InviteStatus.find_by_name("Invited")
    @people = Person.find :all,  :conditions => ['acceptance_status_id = ? and invitestatus_id = ?', accepted.id, invitestatus.id], :order => 'last_name, first_name'
    render :layout => 'content'
  end
  
  def ReportInviteStatus
   
  end

 def invitestatuslist
   @inviteStatus = InviteStatus.find :all
    render :layout => 'plain'
 end

def invitestatuslistwithblank
   @inviteStatus = InviteStatus.find :all
    render :layout => 'plain'
end

def acceptancestatuslist
   @acceptanceStatus = AcceptanceStatus.find :all
    render :layout => 'plain'
end

def acceptancestatuslistwithblank
   @acceptanceStatus = AcceptanceStatus.find :all
    render :layout => 'plain'
end


end