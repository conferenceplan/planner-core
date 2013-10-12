class SurveysController < PlannerController
  
  def index
    @surveys = Survey.all
  end
  
  def list
    @surveys = Survey.all
  end

  def show
    @survey = Survey.find params[:id]
  end

  def create
    @survey = Survey.new params[:survey]
    @survey.save!
  end

  def update
    @survey = Survey.find params[:id]

    @survey.update_attributes(params[:survey])
  end

  def destroy
    survey = Survey.find params[:id]
    
    # Test for groups etc and if survey is "published"
    if (survey.survey_groups.length == 0) && (survey.alias != nil)
      survey.destroy
      render status: :ok, text: {}.to_json
    else
      render status: :bad_request, text: 'Con not delete survey that has groups or is currently published'
    end
  end

end
