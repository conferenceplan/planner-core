class AddressesController < ApplicationController
  before_filter :require_user

  def index
    person = Person.find(params[:person_id])
    
    @urlstr = '/participants/'+ params[:person_id]  + '/postalAddresses/new'
    
    @postalAddresses = person.postal_addresses
    
    @urlemailstr = '/participants/'+ params[:person_id]  + '/emailAddresses/new'
    
    @emailAddresses = person.email_addresses
    
    render :layout => 'content'
  end

end
