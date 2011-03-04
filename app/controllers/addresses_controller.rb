class AddressesController < PlannerController

  def index
    person = Person.find(params[:person_id])
    
    @urlstr = '/participants/'+ params[:person_id]  + '/postalAddresses/new'
    
    @postalAddresses = person.postal_addresses
    
    @urlemailstr = '/participants/'+ params[:person_id]  + '/emailAddresses/new'
    
    @emailAddresses = person.email_addresses

    @urlphonestr = '/participants/'+ params[:person_id]  + '/phoneNumbers/new'
    
    @phoneNumbers= person.phone_numbers
    
    render :layout => 'content'
  end

end
