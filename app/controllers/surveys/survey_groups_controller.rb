class Surveys::SurveyGroupsController < PlannerController
  
  def index
    survey = Survey.find(params[:survey_id])
    @groups = survey.survey_groups # TODO - order by sort_order
  end

  def show
    survey = Survey.find(params[:survey_id])
    @group = survey.survey_groups.find params[:id]
  end

  def create
    survey = Survey.find(params[:survey_id])
    @group = survey.survey_groups.new(params[:survey_group])
    @group.save!
  end

  def update
    survey = Survey.find(params[:survey_id])
    @group = survey.survey_groups.find params[:id]

    @group.update_attributes(params[:survey_group])
  end

  def destroy
    survey = Survey.find(params[:survey_id])
    group = survey.survey_groups.find params[:id]
    group.destroy
  
    render status: :ok, text: {}.to_json
  end

end
