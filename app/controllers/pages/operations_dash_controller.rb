class Pages::OperationsDashController < PlannerController
  def index
    @cellname = params[:cellname]
  end
end
