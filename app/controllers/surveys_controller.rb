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
    
    begin
      survey.destroy
      render status: :ok, text: {}.to_json
    rescue => ex
      render status: :bad_request, text: ex.message
    end
    
  end

end
