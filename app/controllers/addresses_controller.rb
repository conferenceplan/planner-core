class AddressesController < ApplicationController
  def index
    person = Person.find(params[:person_id])
    
    @urlstr = '/participants/'+ params[:person_id]  + '/postalAddresses/new'
    
    @postalAddresses = person.postal_addresses
    
    render :layout => 'content'
  end

end
