class RegistrationDetailsController < ApplicationController
 
  def show
    person = Person.find(params[:person_id])
    
    @registrationDetail = person.registrationDetail
        
    render :layout => 'content'
  end

end
