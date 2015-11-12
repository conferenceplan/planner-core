class RegistrationDetailsController < PlannerController

  def update
    registrationDetail = RegistrationDetail.find(params[:id])
    
    registrationDetail.update_attributes(params[:registration_detail])

    # render :layout => 'content'
    render json: registrationDetail.to_json, :content_type => 'application/json' # need to return the model so that the client has the id
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def create
    if (params[:person_id])
      person = Person.find(params[:person_id])
      registrationDetail = person.create_registrationDetail(params[:registration_detail]);
    else
      # TODO - we may not want to create registration detail without a person...?
      registrationDetail = RegistrationDetail.new(params[:registration_detail]);
    end
    
    # render :layout => 'content'
    render json: registrationDetail.to_json, :content_type => 'application/json' # need to return the model so that the client has the id
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def show
    if (params[:person_id])
      person = Person.find(params[:person_id])

      registrationDetail = person.registrationDetail
    else
      registrationDetail = RegistrationDetail.find(params[:id])
    end
        
    render json: registrationDetail.to_json, :content_type => 'application/json' # need to return the model so that the client has the id
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def index
    if (params[:person_id])
      person = Person.find(params[:person_id])

      @registrationDetail = person.registrationDetail
    else
      @registrationDetail = RegistrationDetail.find(params[:id])
    end
  rescue => ex
    render status: :bad_request, text: ex.message
  end
  
  #
  #
  #
  def destroy
    regDetail = RegistrationDetail.find(params[:id])
    regDetail.destroy
    render status: :ok, text: {}.to_json
  rescue => ex
    render status: :bad_request, text: ex.message
  end

end
