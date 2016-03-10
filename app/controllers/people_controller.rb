#
#
#
class PeopleController < PlannerController

  #
  #
  #
  def destroy
    begin
      Person.transaction do
        person = Person.find(params[:id])
        
        person.removeAllAddresses # If there are any addresses associated with the person then remove them
        person.destroy
        render status: :ok, text: {}.to_json
      end
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end

  #
  #
  #
  def show
    @person = Person.find(params[:id])
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  #
  #
  #
  def create
    begin
      Person.transaction do
        # if pseudonym is empty, we don't want to insert an empty record
        # so delete attributes from input parameter list so
        # it won't get created
        if (params[:pseudonym])
          if (params[:pseudonym][:last_name] != "") || (params[:pseudonym][:first_name] != "") || (params[:pseudonym][:suffix] != "") || (params[:pseudonym][:prefix] != "")
               params[:person][:pseudonym_attributes] = params[:pseudonym]
          end
        end
        
        @person = Person.new(params[:person])
        datasourcetmp = Datasource.find_by_name("Application") # TODO - verify, we need to make sure we have the data-source Application
        @person.datasource = datasourcetmp
        @person.save!
        @person.person_con_state.save!
      end
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end

  #
  #
  #
  def update
    begin
      Person.transaction do
        @person = Person.find(params[:id])
        # if pseudonym is empty, we don't want to insert an empty record
        # so delete attributes from input parameter list so
        # it won't get created. If the pseudonym is getting zeroed
        # out (it existed before and now is not going to exist),
        # we do need to update, so we don't delete the attributes
        if (@person.pseudonym == nil && params[:pseudonym]) #params[:person].has_key?(:pseudonym_attributes))
          if (params[:pseudonym][:last_name] != "") || (params[:pseudonym][:first_name] != "") || (params[:pseudonym][:suffix] != "") || (params[:pseudonym][:prefix] != "")
               params[:person][:pseudonym_attributes] = params[:pseudonym]
          end
        elsif (@person.pseudonym != nil && params[:pseudonym])
          if (params[:pseudonym][:last_name] != "") || (params[:pseudonym][:first_name] != "") || (params[:pseudonym][:suffix] != "") || (params[:pseudonym][:prefix] != "")
            @person.pseudonym.update_attributes(params[:pseudonym])
          else
            @person.pseudonym.destroy
          end
        end
    
        @person.update_attributes(params[:person])
      end
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end

  #
  #
  #
  respond_to :json
  def getList
    rows = params[:rows] ? params[:rows] : 15
    @page = params[:page] ? params[:page].to_i : 1
    
    @currentId = params[:current_selection]
    
    page_to = params[:page_to]
    
    idx = params[:sidx]
    order = params[:sord]
    nameSearch = params[:namesearch]
    scheduled = params[:scheduled] ? params[:scheduled] : false
    filters = params[:filters]
    extraClause = params[:extraClause]
    onlySurveyRespondents = params[:onlySurveyRespondents]
    context = params[:context]
    tags = params[:tags]
    mailing_id = params[:mailing_id]
    email = params[:email]
    operation = params[:op]
    @includeMailings = params[:includeMailings] ? params[:includeMailings] : false
    @includeMailHistory = params[:includeMailHistory] ? params[:includeMailHistory] : false
        
    @count = PeopleService.countPeople filters, extraClause, onlySurveyRespondents, nameSearch, context, tags, nil, mailing_id, operation, scheduled, @includeMailings, @includeMailHistory, email
    
    if page_to && !page_to.empty?
      gotoNum = PeopleService.countPeople filters, extraClause, onlySurveyRespondents, nameSearch, context, tags, page_to, mailing_id, operation, scheduled, @includeMailings, @includeMailHistory, email
      if gotoNum
        @page = (gotoNum / rows.to_i).floor
        @page += 1 if gotoNum % rows.to_i > 0
        @page = 1 if @page <= 0
      end
    end
    
    if rows.to_i > 0
      @nbr_pages = (@count / rows.to_i).floor
      @nbr_pages += 1 if @count % rows.to_i > 0
    else
      @nbr_pages = 1
    end
    
    @people = PeopleService.findPeople rows, @page, idx, order, filters, extraClause, onlySurveyRespondents, nameSearch, context, tags, mailing_id, operation, scheduled, @includeMailings, @includeMailHistory, email
  end
  
  #
  #
  #
  def generateInviteKey
    
    begin
      person = Person.find(params[:id])
      key = MailService.generateSurveyKey person
      
      render status: :ok, text: {}.to_json
    rescue => ex
      render status: :bad_request, text: ex.message
    end
    
  end
  
  #
  # The invite status etc. should be in a seperate controller. TODO
  #
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
  
  ############
  def exportbiolist
    accepted = AcceptanceStatus.find_by_name("Accepted")
    invitestatus = InviteStatus.find_by_name("Invited")
    
    @people = findAllPeopleByInviteAndAcceptance(invitestatus.id, accepted.id)
    
    render :layout => 'content'
  end
  
end