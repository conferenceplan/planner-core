class AvailableDatesController < PlannerController
  
  def update
    availableDate = AvailableDate.find(params[:id])
    availableDate.update_attributes(params[:available_date])
    render json: availableDate.to_json, :content_type => 'application/json'
  end
  
  def create
    if (params[:person_id])
      person = Person.find(params[:person_id])
      availableDate = person.create_available_date(updateParams);
      availableDate.update_attributes(params[:available_date])
    else
      availableDate = AvailableDates.new(params[:available_date])
    end
    
    availableDate.save
    
    render json: availableDate.to_json, :content_type => 'application/json'
  end

  def show
    if (params[:person_id])
       person = Person.find(params[:person_id])
       availableDate = person.available_date
    else
      availableDate = AvailableDate.find(params[:id])
    end
    
    render json: availableDate.to_json, :content_type => 'application/json'
  end

  def destroy
    availableDate = AvailableDate.find(params[:id])
    availableDate.destroy
    render status: :ok, text: {}.to_json
  end

  def index
    # TODO - to be checked
    availableDates = AvailableDate.find :all
    render json: availableDates.to_json, :content_type => 'application/json'
  end

end
