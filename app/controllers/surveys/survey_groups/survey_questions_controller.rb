#
#
#
class Surveys::SurveyGroups::SurveyQuestionsController < PlannerController
  
  def index
    survey = Survey.find(params[:survey_id])
    group = survey.survey_groups.find params[:survey_group_id]
    @questions = group.survey_questions
  end

  def show
    survey = Survey.find(params[:survey_id])
    group = survey.survey_groups.find params[:survey_group_id]
    @question = group.survey_questions.find params[:id]
  end
  
  def create
    survey = Survey.find(params[:survey_id])
    group = survey.survey_groups.find params[:survey_group_id]
    @question = group.survey_questions.new(params[:survey_question])
    
    if @question.save!
      @question.updateTimeConflict(params[:survey_question][:new_answer_attributes]); # TODO - check this
    end
  end

  def update
    survey = Survey.find(params[:survey_id])
    group = survey.survey_groups.find params[:survey_group_id]
    @question = group.survey_questions.find params[:id]

    if @question.update_attributes(params[:survey_question])
      # If we have answers to add to the question then do so here
      # TODO - if the question is a type that does not accept answers then do no worry... make sure the answers if any are cleared
      @question.updateTimeConflict(params[:survey_question][:existing_answer_attributes]);
    end
  end

  def destroy
    survey = Survey.find(params[:survey_id])
    group = survey.survey_groups.find params[:survey_group_id]
    question = group.survey_questions.find params[:id]
    
    question.destroy
    
    render status: :ok, text: {}.to_json
  end

end
