class AvailableDatesController < PlannerController
  
  def update
    @availableDate = AvailableDate.find(params[:id])
    @availableDate.update_attributes(params[:available_date])
  end
  
  def create
    if (params[:person_id])
      person = Person.find(params[:person_id])
      @availableDate = person.create_available_date();
      @availableDate.update_attributes(params[:available_date])
    else
      @availableDate = AvailableDates.new(params[:available_date])
    end
    
    @availableDate.save
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def show
    if (params[:person_id])
       person = Person.find(params[:person_id])
       @availableDate = person.available_date
    else
      @availableDate = AvailableDate.find(params[:id])
    end
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def destroy
    availableDate = AvailableDate.find(params[:id])
    availableDate.destroy
    render status: :ok, text: {}.to_json
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def index
    # TODO - to be checked
    if (params[:person_id])
       person = Person.find(params[:person_id])
       @availableDate = person.available_date
    else
      @availableDate = AvailableDate.find(params[:id])
    end
  rescue => ex
    render status: :bad_request, text: ex.message
  end

end
