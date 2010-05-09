class AddressesController < ApplicationController
  def index
    person = Person.find(params[:person_id])
    
    @addresses = person.postal_addresses
    
    render :layout => 'content'
  end
end
