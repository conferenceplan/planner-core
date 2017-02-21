#
#
#
class PeopleController < PlannerController

  #
  #
  #
  def merge
    Person.transaction do
      src_person_id = params[:src_person_id]
      dest_person_id = params[:dest_person_id]
      to_destination = params[:direction] != "true"
      
      if to_destination
        src_person = Person.find src_person_id
        dest_person = Person.find dest_person_id
      else  # we are merging in the other direction
        src_person = Person.find dest_person_id
        dest_person = Person.find src_person_id
      end
      
      if !src_person || !dest_person
        raise I18n.t("planner.core.errors.people-not-found")
      end
      
      PeopleService.merge_people(src_person, dest_person)
      
      # delete the src_person
      src_person.destroy
      
      render status: :ok, json: {person_id: dest_person.id}.to_json
    end

  rescue => ex
    render status: :bad_request, text: ex.message
  end

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
        datasourcetmp = Datasource.find_by(name: "Application") # TODO - verify, we need to make sure we have the data-source Application
        @person.datasource = datasourcetmp

        
        @person = update_default_email_address @person

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
        @person = update_default_email_address @person
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
    only_relevent_people = params[:only_relevent] ? (params[:only_relevent] == "true") : false

# TODO - fix page_to does a find as well....
    @count = PeopleService.countPeople filters, extraClause, onlySurveyRespondents, nameSearch, context, 
                                        tags, nil, mailing_id, operation, scheduled, @includeMailings, @includeMailHistory, email,
                                        only_relevent_people
    
    if page_to && !page_to.empty?
      gotoNum = PeopleService.countPeople filters, extraClause, onlySurveyRespondents, nameSearch, context, 
                                        tags, page_to, mailing_id, operation, scheduled, @includeMailings, @includeMailHistory, email,
                                        only_relevent_people
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
    
    @people = PeopleService.findPeople rows, @page, idx, order, filters, extraClause, onlySurveyRespondents,
                  nameSearch, context, tags, mailing_id, operation, scheduled, 
                  @includeMailings, @includeMailHistory, email, only_relevent_people
  end
  
  #
  #
  #
  def generateInviteKey
    
    begin
      person = Person.find(params[:id])
      MailService.generateSurveyKey person
      
      render status: :ok, text: {}.to_json
    rescue => ex
      render status: :bad_request, text: ex.message
    end
    
  end
  
  #
  # The invite status etc. should be in a seperate controller. TODO
  #
  def invitestatuslist
    @inviteStatus = InviteStatus.all
    render :layout => 'plain'
  end

  def invitestatuslistwithblank
     @inviteStatus = InviteStatus.all
      render :layout => 'plain'
  end
  
  def acceptancestatuslist
     @acceptanceStatus = AcceptanceStatus.all
      render :layout => 'plain'
  end
  
  def acceptancestatuslistwithblank
     @acceptanceStatus = AcceptanceStatus.all
      render :layout => 'plain'
  end
  
  ############
  def exportbiolist
    accepted = AcceptanceStatus.find_by(name: "Accepted")
    invitestatus = InviteStatus.find_by(name: "Invited")
    
    @people = findAllPeopleByInviteAndAcceptance(invitestatus.id, accepted.id)
    
    render :layout => 'content'
  end


  private
  def update_default_email_address person
    # Email address
    if params[:default_email_address] && params[:default_email_address].present? && params[:default_email_address][:email].present?
      email = params[:default_email_address][:email]
      label = params[:default_email_address][:label]
      email_address = person.email_addresses.find_by(email: email)
      if email_address.present?
        email_address.email = email
        email_address.label = label
        email_address.isdefault = true if !email_address.isdefault
        email_address.save!
      else
        person.updateDefaultEmail(email, label: label)
      end
    else # make sure it gets deleted
      person.getDefaultEmail.destroy if person.getDefaultEmail && person.getDefaultEmail.isdefault
    end

    person
  end
  
end