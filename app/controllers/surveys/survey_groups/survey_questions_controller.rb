#
#
#
class Surveys::SurveyGroups::SurveyQuestionsController < PlannerController
  
  #
  #
  #
  def index
    survey = Survey.find(params[:survey_id])
    group = survey.survey_groups.find params[:survey_group_id]
    @questions = group.survey_questions
  end

  #
  #
  #
  def show
    survey = Survey.find(params[:survey_id])
    group = survey.survey_groups.find params[:survey_group_id]
    @question = group.survey_questions.find params[:id]
  end
  
  #
  #
  #
  def create
    survey = Survey.find(params[:survey_id])
    group = survey.survey_groups.find params[:survey_group_id]
    
    begin
      SurveyQuestion.transaction do
        @question = group.survey_questions.new(params[:survey_question])
        
        if params[:survey_format]
          @question.survey_format = SurveyFormat.new(params[:survey_format])
          @question.survey_format.save!
        end
          
        if @question.save!
          @question.update_answers(params[:survey_answers]) if params[:survey_answers]
        end
      end
    rescue Exception
      raise
    end
  end

  #
  #
  #
  def update
    begin
      SurveyQuestion.transaction do
        survey = Survey.find(params[:survey_id])
        group = survey.survey_groups.find params[:survey_group_id]
        @question = group.survey_questions.find params[:id]
    
        @question.update_attributes!(params[:survey_question])
    
        if params[:survey_format]
          format = @question.survey_format
          if format
            format.update_attributes(params[:survey_format])
          else  
            format = SurveyFormat.new(params[:survey_format])
            @question.survey_format = format
            format.save!
          end
        end
    
        # If we have answers to add to the question then do so here
        if params[:survey_answers]
          @question.update_answers(params[:survey_answers]);
        else # clear out the answers
          @question.survey_answers.delete_all
        end
    
        @question.save!
      end
    rescue Exception
      raise
    end
  end

  #
  #
  #
  def destroy
    survey = Survey.find(params[:survey_id])
    group = survey.survey_groups.find params[:survey_group_id]
    question = group.survey_questions.find params[:id]
    
    question.destroy
    
    render status: :ok, text: {}.to_json
  end

end
