class Pages::CommunicationsDashController < PlannerController
  def index
    @cellname = params[:cellname]
  end
end
