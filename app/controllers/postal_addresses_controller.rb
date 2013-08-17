class PostalAddressesController < PlannerController

  def update
    postalAddress = PostalAddress.find(params[:id])

    postalAddress.update_attributes(params[:postal_address])

    render json: postalAddress.to_json, :content_type => 'application/json'
  end

  def create
    if (params[:person_id])
      person = Person.find(params[:person_id])      
      postalAddress = person.postal_addresses.new(params[:postal_address])
      person.save!
    else
      # CHECK - we may not want to create an address without having a person to assigned it to it?
      postalAddress = PostalAddress.new(params[:postal_address]);
      postalAddress.save!
    end

    render json: postalAddress.to_json, :content_type => 'application/json'
  end

  def show
    postalAddress = PostalAddress.find(params[:id])
    render json: postalAddress.to_json, :content_type => 'application/json'
  end

  def destroy
    # TODO - make sure that this cleans up the relationships in the Address table
    # TODO - this is not correct, the address should be removed from the person then only
    # destroyed if there are no other people referencing the address...
    postalAddress = PostalAddress.find(params[:id])
    postalAddress.destroy
    render text: 'OK'
  end

  def index
    person = Person.find(params[:person_id])
   
    postalAddresses = person.postal_addresses
    
    render json: postalAddresses.to_json, :content_type => 'application/json'
  end
end

