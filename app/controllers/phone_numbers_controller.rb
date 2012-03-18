class PhoneNumbersController < PlannerController

  def new
    if (params[:person_id])
      @urlstr = '/participants/' + params[:person_id] + '/phoneNumbers'
    else
      @urlstr = '/phoneNumbers'
    end
    @phoneNumber = PhoneNumber.new 

    render :layout => 'content'
  end

  def edit
    @phoneNumber= PhoneNumber.find(params[:id])
    render :layout => 'content'
  end

  def update
    @phoneNumber = PhoneNumber.find(params[:id])

    if @phoneNumber.update_attributes(params[:phone_number])
      redirect_to :action => 'show', :id => @phoneNumber
    else
      render :action => 'edit'
    end
  end

  def create
    if (params[:person_id])
      @person = Person.find(params[:person_id])      
      @phoneNumber = @person.phone_numbers.new(params[:phone_number])
    else
      # TODO - we may not want to create an address without having a person to assigned it to it?
      @phoneNumber = PhoneNumber.new(params[:phone_number]);
      if (@phoneNumber.save)
        redirect_to :action => 'show', :id => @phoneNumber
      else
        render :action => 'new'
      end
      return
    end

    if (@person.save)
#      We want to go back to?
       redirect_to :action => 'show', :id => @phoneNumber
    else
      render :action => 'new'
    end 
  end

  def show
    @phoneNumber = PhoneNumber.find(params[:id])

    render :layout => 'content'
  end

  def destroy
    # TODO - make sure that this cleans up the relationships in the Address table
    # TODO - this is not correct, the number should be removed from the person then only
    # destroyed if there are no other people referencing the address...
    @phoneNumber = PhoneNumber.find(params[:id])
    @phoneNumber.destroy
    render :layout => 'success'
  end

  def index
    render :layout => 'content'
  end
end
