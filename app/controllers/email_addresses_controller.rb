class EmailAddressesController < PlannerController

  def labels
    query = params[:query] ? params[:query] : ""
    
    res = EmailAddress.where("label like ?", "%" + query + "%").select("distinct label")
    
    render json: res.collect{|r| r.label}.to_json, :content_type => 'application/json'
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def update
    emailAddress = EmailAddress.find(params[:id])

    emailAddress.update_attributes(params[:email_address])

    render json: emailAddress.to_json, :content_type => 'application/json'
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def create
    if (params[:person_id])
      person = Person.find(params[:person_id])      
      emailAddress = person.email_addresses.new(params[:email_address])
      person.save!
    else
      # CHECK - we may not want to create an address without having a person to assigned it to it?
      emailAddress = EmailAddress.new(params[:email_address]);
      emailAddress.save!
    end

    render json: emailAddress.to_json, :content_type => 'application/json'
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def show
    emailAddress = EmailAddress.find(params[:id])

    render json: emailAddress.to_json, :content_type => 'application/json'
  end

  def destroy
    # TODO - make sure that this cleans up the relationships in the Address table
    emailAddress = EmailAddress.find(params[:id])
    emailAddress.destroy
    render status: :ok, text: {}.to_json
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def index
    person = Person.find(params[:person_id]) # TODO
   
    emailAddresses = person.email_addresses
    
    render json: emailAddresses.to_json, :content_type => 'application/json'
  rescue => ex
    render status: :bad_request, text: ex.message
  end
  
end
