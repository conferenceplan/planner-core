class AvailabilitiesController < PlannerController
  def index
    @person = Person.find(params[:person_id])      

    @availableDates = @person.available_date if @person
    
    @excludedItems = @person.excluded_items if @person
   
    @excludedTimesGroup = @person.excluded_periods if @person
  end
end
