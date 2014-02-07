class Pages::MobileDashController < PlannerController
  def index
    @cellname = params[:cellname]
  end
end
