class ExcludedItemController < PlannerController

  def show
   if (params[:person_id])
       @person = Person.find(params[:person_id])
       @excludedItems = person.excluded_items
    end
    
    render :layout => 'content'
  end
end
