class RegistrationDetailsController < PlannerController

  def edit
    @registrationDetail = RegistrationDetail.find(params[:id])
    @urlstr = '/registrationDetails/' + params[:id]
    render :layout => 'content'
  end

  def update
    @registrationDetail = RegistrationDetail.find(params[:id])
    @urlstr = '/registrationDetails/' + params[:id]

    if @registrationDetail.update_attributes(params[:registration_detail])
      redirect_to :action => 'show', :id => @registrationDetail
    else
      render :action => 'edit'
    end
  end

  def new
    if (params[:person_id])
      @urlstr = '/participants/' + params[:person_id] + '/registrationDetail'
    else
      @urlstr = '/registrationDetails'
    end
    @registrationDetail = RegistrationDetail.new 

    render :layout => 'content'
  end

   def create
    if (params[:person_id])
      @person = Person.find(params[:person_id])
      @registrationDetail = @person.create_registrationDetail(params[:registration_detail]);
    else
      # TODO - we may not want to create registration detail without a person...?
      @registrationDetail = RegistrationDetail.new(params[:registration_detail]);
    end
    
    if (@registrationDetail.save)
       redirect_to :action => 'show', :id => @registrationDetail
    else
      render :action => 'new'
    end 
  end

  def show
    if (params[:person_id])
      person = Person.find(params[:person_id])

     @urlstr = '/participants/'+ params[:person_id]  + '/registrationDetail/new'

      @registrationDetail = person.registrationDetail
    else
      @registrationDetail = RegistrationDetail.find(params[:id])
    end
        
    render :layout => 'content'
  end

  def index
    render :layout => 'content'
  end

end
