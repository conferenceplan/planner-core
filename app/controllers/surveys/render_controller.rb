#
# Render the survey
#
class Surveys::RenderController < ApplicationController
    layout "survey"

  def index
    @survey = Survey.find(params[:survey_id])
  end
end
