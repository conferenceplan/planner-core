class Surveys::SurveyGroups::SurveyQuestionsController < PlannerController
  def index
    @survey = Survey.find(params[:survey_id])
    @group = @survey.survey_groups.find params[:survey_group_id]
    @questions = @group.survey_questions

    render :layout => 'plain'
  end

  def show
    @survey = Survey.find(params[:survey_id])
    @group = @survey.survey_groups.find params[:survey_group_id]
    @question = @group.survey_questions.find params[:id]
    
    render :layout => 'content'
  end

  def new
    @survey = Survey.find(params[:survey_id])
    @group = @survey.survey_groups.find params[:survey_group_id]
    @question = @group.survey_questions.new
    @question.survey_format = SurveyFormat.new
    
    render :layout => 'content'
  end

  def edit
    @survey = Survey.find(params[:survey_id])
    @group = @survey.survey_groups.find params[:survey_group_id]
    @question = @group.survey_questions.find params[:id]
    if @question.survey_format == nil
      @question.survey_format = SurveyFormat.new
    end

    render :layout => 'content'
  end

  def update
    @survey = Survey.find(params[:survey_id])
    @group = @survey.survey_groups.find params[:survey_group_id]
    @question = @group.survey_questions.find params[:id]

    if @question.update_attributes(params[:survey_question])
      # Go back to the main page
      @questions = @group.survey_questions
      render :show, :layout => 'content'
      # render :question_list, :layout => 'plain'
    else
      render :action => 'edit', :status => 500, :layout => 'content'
    end
  end

  def destroy
    @survey = Survey.find(params[:survey_id])
    @group = @survey.survey_groups.find params[:survey_group_id]
    @question = @group.survey_questions.find params[:id]
    
    @question.destroy
    
    @questions = @group.survey_questions
    render :action => 'index', :layout => 'plain'
  end

  def create
    @survey = Survey.find(params[:survey_id])
    @group = @survey.survey_groups.find params[:survey_group_id]
    @question = @group.survey_questions.new(params[:survey_question])
    
    if @question.save
      @questions = @group.survey_questions
      render :action => 'index', :layout => 'plain'
    else
      render :action => 'new'
    end
  end

end
