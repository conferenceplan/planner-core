class Pages::ItemsDashController < PlannerController
  
  def index
    @prog_item = params.has_key?(:prog_item) ? params[:prog_item] : nil
    
    @cellname = params[:cellname]
  end
  
end
