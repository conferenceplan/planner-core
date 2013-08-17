class AddressesController < PlannerController

  def index
    person = Person.find(params[:person_id])
    
    @postalAddresses = person.postal_addresses
    @emailAddresses = person.email_addresses
    @phoneNumbers= person.phone_numbers
    
    render :layout => 'content'
  end

end
