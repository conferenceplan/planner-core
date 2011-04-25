class ExcludedItemsSurveyMapsController < PlannerController
  def index
    @programmeItem = ProgrammeItem.find(params[:programme_item_id])

    @excludedItemsSurveyMaps = @programmeItem.excluded_items_survey_maps
    @urlstr = '/programme_items/'+ params[:programme_item_id]  + '/excluded_items_survey_maps/new'
    render :layout => 'content'
  end
  
  def show
    if (params[:programme_item_id])
       @programme_item = ProgrammeItem.find(params[:programme_item_id])
       @urlstr = '/programme_items/'+ params[:programme_item_id]  + '/excluded_items_survey_maps/new'

       @excludedItemsSurveyMaps = @programme_item.excluded_items_survey_maps
       
    else
      @urlstr = '/excluded_items_survey_maps/new'

      @excludedItemsSurveyMaps = ExcludedItemsSurveyMap.find(params[:id])
    end
    
    render :layout => 'content'
  end
  
  def create
    
     @programmeItem = ProgrammeItem.find(params[:programme_item_id])
     @mappedQuestion = MappedSurveyQuestion.find(params[:excluded_items_survey_map][:mapped_survey_question_id])
     @excludedItemsSurveyMap = ExcludedItemsSurveyMap.new(:programme_item_id => params[:programme_item_id],
                                 :mapped_survey_question_id => params[:excluded_items_survey_map][:mapped_survey_question_id])
     @programmeItem.excluded_items_survey_maps << @excludedItemsSurveyMap
     
   
    if (@programmeItem.save)
#      We want to go back to?
       redirect_to :action => 'show', :id => @excludedItemsSurveyMap

 #         redirect_to :action => 'show', :id => @excludedItemsSurveyMap
    else
         render :action => 'new'
    end

end
  
  def new
     if (params[:programme_item_id])
      @urlstr = '/programme_items/' + params[:programme_item_id] + '/excluded_items_survey_maps'
    else
      @urlstr = '/excluded_items_survey_maps'
    end
    @excludedItemsSurveyMap = ExcludedItemsSurveyMap.new
    @excludedItemsSurveyMap.programme_item_id = params[:programme_item_id]
    
    render :layout => 'content'
  end
  
  def edit
    @excludedItemsSurveyMap = ExcludedItemsSurveyMap.find(params[:id])
    
    @urlstr = '/available_dates/' + params[:id]
    render :layout => 'content'
  end
  
  def update

    @excludedItemsSurveyMap = ExcludedItemsSurveyMap.find(params[:id])
    
    if @excludedItemsSurveyMap.update_attributes(updateParams)
       redirect_to :action => 'show', :id => params[:id]

    else
      render :action => 'edit'
    end
    
  end
  
  def destroy
    @excludedItemsSurveyMap = ExcludedItemsSurveyMap.find(params[:id])
    @programItem = @excludedItemsSurveyMap.programme_item
    @excludedItemsSurveyMap.destroy
    gopath = "/programme_items/" + @programItem.id.to_s + "/excluded_items_survey_map"
    redirect_to gopath
  end
end
