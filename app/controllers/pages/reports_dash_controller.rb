class Pages::ReportsDashController < PlannerController
  def index
    @cellname = params[:cellname]
  end
end
