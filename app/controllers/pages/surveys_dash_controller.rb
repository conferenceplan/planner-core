class Pages::SurveysDashController < PlannerController
  def index
    @cellname = params[:cellname]
  end
end
