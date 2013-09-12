class Pages::ScheduleDashController < PlannerController
  def index
    @cellname = params[:cellname]
  end
end
