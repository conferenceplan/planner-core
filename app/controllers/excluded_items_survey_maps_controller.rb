class ExcludedItemsSurveyMapsController < PlannerController
  #
  #
  #
  def index
    item = ProgrammeItem.find(params[:programme_item_id])

    @exclusions = item.excluded_items_survey_maps
  end
  
  #
  #
  #
  def show
    @exclusion = ExcludedItemsSurveyMap.find(params[:id])
  end
  
  #
  #
  #
  def create
    item = ProgrammeItem.find(params[:programme_item_id])
    answer = SurveyAnswer.find(params[:excluded_items_survey_map][:survey_answer_id])

    begin
      ProgrammeItem.transaction do
        exclusion = item.excluded_items_survey_maps.new(:survey_answer_id => answer.id)
        
        programmeItem.save!
        
        @exclusions = item.excluded_items_survey_maps
      end
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end
  
  #
  #
  #
  def destroy
    exclusion = ExcludedItemsSurveyMap.find(params[:id])

    begin
      ProgrammeItem.transaction do
        exclusion.destroy
        
        render status: :ok, text: {}.to_json
      end
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end
  
  # TODO - is this used? i.e. user will do a delete and add instead
  # def update
    # begin
      # ProgrammeItem.transaction do
        # excludedItemsSurveyMap = ExcludedItemsSurveyMap.find(params[:id])
        # excludedItemsSurveyMap.update_attributes(updateParams)
#         
        # render json: excludedItemsSurveyMap.to_json, :content_type => 'application/json'
      # end
    # rescue => ex
      # render status: :bad_request, text: ex.message
    # end
  # end
  
end
