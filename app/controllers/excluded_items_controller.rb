class ExcludedItemsController < PlannerController

  #
  def index
    @answers = SurveyService.findAnswersForExcludedItems
  end
  
  #
  def show
    @answer = SurveyAnswer.find params[:id], :include => :programme_items
  end
  
  # update the exclusions
  def exclusions
    @answer = SurveyAnswer.find params[:id] #, :include => :programme_items
    items = params[:programme_items]
    
    # add the items to the map of exclusions i.e. the programme items that this answer points to
    begin
      SurveyAnswer.transaction do
        @answer.programme_items.clear
        if items
          items.each do |item|
            exclusion = ExcludedItemsSurveyMap.create(:programme_item_id => item['id'], :survey_answer_id => @answer.id)
            exclusion.save
          end
        end
        @answer = SurveyAnswer.find params[:id], :include => :programme_items
      end
    rescue => ex
      render status: :bad_request, text: ex.message
    end    
  end

end
