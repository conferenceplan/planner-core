class Surveys::SurveyGroupsController < PlannerController
  
  def index
    survey = Survey.find(params[:survey_id])
    @groups = survey.survey_groups # TODO - order by sort_order??
  end

  def show
    survey = Survey.find(params[:survey_id])
    @group = survey.survey_groups.find params[:id]
  end

  def create
    survey = Survey.find(params[:survey_id])
    begin
      SurveyGroup.transaction do
        @group = survey.survey_groups.new(params[:survey_group])
        # If we have a survey_format we need to create that and associate with the group
        format = SurveyFormat.new(params[:survey_format])
        format.save!
        @group.survey_format = format
        @group.save!
      end
    rescue Exception
      raise
    end
  end

  def update
    survey = Survey.find(params[:survey_id])
    @group = survey.survey_groups.find params[:id]
    begin
      SurveyGroup.transaction do
        @group.update_attributes(params[:survey_group])
        
        if params[:survey_format]
          format = @group.survey_format
          if format
            format.update_attributes(params[:survey_format])
          else  
            format = SurveyFormat.new(params[:survey_format])
            @group.survey_format = format
            format.save!
            @group.save!
          end
        end
      end
    rescue Exception
      raise
    end
  end

  def destroy
    survey = Survey.find(params[:survey_id])
    group = survey.survey_groups.find params[:id]
    group.destroy
  
    render status: :ok, text: {}.to_json
  end

end
