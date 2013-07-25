class AvailabilitiesController < PlannerController
  def index
    @person = Person.find(params[:person_id])
        
    @urlstr = '/participants/'+ params[:person_id]  + '/available_dates/new'

    @availableDate = @person.available_date
    
    @excludedItems = @person.excluded_items
   
    @excludedGroup = @person.GetExcludedTimesGroup
    
    
 
 #   @excludedItems = person.excluded_items
    
    
    render :layout => 'content'
  end

end
