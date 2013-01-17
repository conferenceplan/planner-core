class PostalAddressesController < PlannerController

  def new
    if (params[:person_id])
      @urlstr = '/participants/' + params[:person_id] + '/postalAddresses'
    else
      @urlstr = '/postal_addresses'
    end
    @postalAddress = PostalAddress.new 

    render :layout => 'content'
  end

  def edit
    @postalAddress = PostalAddress.find(params[:id])
    render :layout => 'content'
  end

  def update
    @postalAddress = PostalAddress.find(params[:id])

    if @postalAddress.update_attributes(params[:postal_address])
      redirect_to :action => 'show', :id => @postalAddress
    else
      render :action => 'edit'
    end
  end

  def create
    if (params[:person_id])
      @person = Person.find(params[:person_id])      
      @postalAddress = @person.postal_addresses.new(params[:postal_address])
    else
      # TODO - we may not want to create an address without having a person to assigned it to it?
      @postalAddress = PostalAddress.new(params[:postal_address]);
      if (@postalAddress.save)
        redirect_to :action => 'show', :id => @postalAddress
      else
        render :action => 'new'
      end
      return
    end

    if (@person.save)
#      We want to go back to?
       redirect_to :action => 'show', :id => @postalAddress
    else
      render :action => 'new'
    end 
  end

  def show
    @postalAddress = PostalAddress.find(params[:id])

    render :layout => 'content'
  end

  def destroy
    # TODO - make sure that this cleans up the relationships in the Address table
    # TODO - this is not correct, the address should be removed from the person then only
    # destroyed if there are no other people referencing the address...
    @postalAddress = PostalAddress.find(params[:id])
    @postalAddress.destroy
    render :layout => 'success'
  end

  def index
#    person = Person.find(params[:person_id])
#    
#    @postalAddresses = person.postal_addresses
    
    render :layout => 'content'
  end
end
