class Pages::ParticipantsDashController < PlannerController
  def index
    @module_name = if params[:module_name]
                     params[:module_name]
                   else
                     'participants'
                   end
    @cellname = params[:cellname]
  end
end
