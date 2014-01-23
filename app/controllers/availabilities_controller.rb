class AvailabilitiesController < PlannerController
  def index
    @availableDates = @person.available_date
    
    @excludedItems = @person.excluded_items
   
    @excludedTimesGroup = @person.excluded_periods
  end
end
