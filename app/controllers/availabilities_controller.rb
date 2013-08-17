class AvailabilitiesController < PlannerController
  def index
    @person = Person.find(params[:person_id])
        
    @urlstr = '/participants/'+ params[:person_id]  + '/available_dates/new'

    @availableDates = @person.available_date
    
    @excludedItems = @person.excluded_items
   
    @excludedTimesGroup = @person.excluded_periods
    
    render :layout => 'content'
  end

end
