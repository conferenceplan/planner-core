class EmailAddressesController < ApplicationController
  before_filter :require_user

  def new
    if (params[:person_id])
      @urlstr = '/participants/' + params[:person_id] + '/emailAddresses'
    else
      @urlstr = '/emailAddresses'
    end
    @emailAddress = EmailAddress.new 

    render :layout => 'content'
  end

  def edit
    @emailAddress = EmailAddress.find(params[:id])
    render :layout => 'content'
  end

  def update
    @emailAddress = EmailAddress.find(params[:id])

    if @emailAddress.update_attributes(params[:email_address])
      redirect_to :action => 'show', :id => @emailAddress
    else
      render :action => 'edit'
    end
  end

  def create
    if (params[:person_id])
      @person = Person.find(params[:person_id])      
      @emailAddress = @person.email_addresses.new(params[:email_address]);
    else
      # TODO - we may not want to create an address without having a person to assigned it to it?
      @emailAddress = EmailAddress.new(params[:email_address]);
    end
    
    if (@person.save)
#      We want to go back to?
       redirect_to :action => 'show', :id => @emailAddress
    else
      render :action => 'new'
    end 
  end

  def show
    @emailAddress = EmailAddress.find(params[:id])

    render :layout => 'content'
  end

  def destroy
    # TODO - make sure that this cleans up the relationships in the Address table
    @emailAddress = EmailAddress.find(params[:id])
    @emailAddress.destroy
    render :layout => 'success'
  end

  def index
#    person = Person.find(params[:person_id])
#    
#    @emailAddresses = person.email_addresses
    
    render :layout => 'content'
  end
end

