class MappedSurveyQuestionsController < PlannerController
  def index
    @mapped_survey_questions = MappedSurveyQuestion.find :all
  end
  def show
    @mapped_survey_question = MappedSurveyQuestion.find(params[:id])
  end
  def create
    @mapped_survey_question = MappedSurveyQuestion.new(params[:mapped_survey_question])
    if (@mapped_survey_question.save)
       redirect_to :action => 'index'
    else
      render :action => 'new'
    end 
  end
  def new
    @mapped_survey_question = MappedSurveyQuestion.new
  end
  
  def edit
    @mapped_survey_question = MappedSurveyQuestion.find(params[:id])
  end
  
  def update
    @mapped_survey_question = MappedSurveyQuestion.find(params[:id])
    if @mapped_survey_question.update_attributes(params[:mapped_survey_question])
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @mapped_survey_question = MappedSurveyQuestion.find(params[:id])
    @mapped_survey_question.destroy
    redirect_to :action => 'index'
  end
 
end
