class Surveys::SurveyGroupsController < PlannerController
  def index
    @survey = Survey.find(params[:survey_id])
    @groups = @survey.survey_groups

    render :layout => 'plain'
  end

  def show
    @survey = Survey.find(params[:survey_id])
    @group = @survey.survey_groups.find params[:id]
    @showQuestions = params[:show_questions]

    render :layout => 'content'
  end

  def new
    @survey = Survey.find(params[:survey_id])
    @group = @survey.survey_groups.new
    @group.survey_format = SurveyFormat.new

    render :layout => 'content'
  end

  def edit
    @survey = Survey.find(params[:survey_id])
    @group = @survey.survey_groups.find params[:id]

    render :layout => 'content'
  end

  def update
    @survey = Survey.find(params[:survey_id])
    @group = @survey.survey_groups.find params[:id]
    @showQuestions = true
    if @group.update_attributes(params[:survey_group])
      # Go back to the main page
      @groups = @survey.survey_groups
      render :show, :layout => 'plain'
    else
      render :action => 'edit', :status => 500, :layout => 'content'
    end
  end

  def destroy
    @survey = Survey.find(params[:survey_id])
    @group = @survey.survey_groups.find params[:id]
    @group.destroy
  
    @groups = @survey.survey_groups

    render :group_list, :layout => 'plain'
  end

  def create
    @survey = Survey.find(params[:survey_id])
    @group = @survey.survey_groups.new(params[:survey_group])

    if @group.save
      @groups = @survey.survey_groups
      render :group_list, :layout => 'plain'
    else
      render :action => 'new'
    end
  end

end
