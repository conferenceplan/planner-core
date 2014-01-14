class Pages::PublicationsDashController < PlannerController
  def index
    @cellname = params[:cellname]
  end
end
