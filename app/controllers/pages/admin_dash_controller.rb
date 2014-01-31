class Pages::AdminDashController < PlannerController
  def index
    @cellname = params[:cellname]
  end
end
