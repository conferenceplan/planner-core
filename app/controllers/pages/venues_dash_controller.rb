class Pages::VenuesDashController < PlannerController
  def index
    @cellname = params[:cellname]
  end
end
