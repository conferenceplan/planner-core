class AvailableDatesController < PlannerController
  
  def index
    @availableDates = AvailableDate.find :all
  end
  
  def show
    if (params[:person_id])
       @person = Person.find(params[:person_id])
       @urlstr = '/participants/'+ params[:person_id]  + '/available_dates/new'

       @availableDate = @person.available_date
       
    else
      @urlstr = '/available_dates/new'

      @availableDate = AvailableDate.find(params[:id])
    end
    
    render :layout => 'content'
  end
  
  def create
    
    if (params[:person_id])
      @person = Person.find(params[:person_id])
      startTime = GetDateFromInput(params[:available_date],'start_time')
      endTime = GetDateFromInput(params[:available_date],'end_time')
      updateParams = { :start_time => startTime, :end_time => endTime}
     
      @availableDate = @person.create_available_date(updateParams);
    else
      @availableDate = AvailableDates.new(params[:available_date])
    end
    
    if (@availableDate.save)
#      We want to go back to?
          redirect_to :action => 'show', :id => @availableDate
    else
         render :action => 'new'
    end

end
  
  def new
     if (params[:person_id])
      @urlstr = '/participants/' + params[:person_id] + '/available_dates'
    else
      @urlstr = '/available_dates'
    end
    @availableDate = AvailableDate.new
    person = Person.find(params[:person_id])
    
    @availableDate.start_time  =  GetDefaultStart() # TODO - limit by start date at con from survey if answered

    @availableDate.end_time =  GetDefaultEnd() # TODO - limit by end date at con from survey if answered
    
    render :layout => 'content'
  end
  
  def edit
    @availableDate = AvailableDate.find(params[:id])
    
    @urlstr = '/available_dates/' + params[:id]
    render :layout => 'content'
  end
  
  def update

    @availableDate = AvailableDate.find(params[:id])
    startTime = GetDateFromInput(params[:available_date],'start_time')
    endTime = GetDateFromInput(params[:available_date],'end_time')
    updateParams = { :start_time => startTime, :end_time => endTime}
    
    if @availableDate.update_attributes(updateParams)
      redirect_to :action => 'show', :id => @availableDate
    else
      render :action => 'edit'
    end
    
  end
  
  def destroy
    @availableDate = AvailableDate.find(params[:id])
    @availableDate.destroy
    redirect_to :action => 'index'
  end
  
  def GetDefaultStart
    return Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + 12.hours
  end
  
  def GetDefaultEnd
    return Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + (SITE_CONFIG[:conference][:number_of_days]-1).days + 16.hours;
  end
 
  def GetDateFromInput(inParams,baseParamName)
       updatedValueYear = inParams[baseParamName+'(1i)']
       updatedValueMon = inParams[baseParamName+'(2i)']
       updatedValueDay = inParams[baseParamName+'(3i)']
       updatedValueHour = inParams[baseParamName+'(4i)']
       updatedValueMinute = inParams[baseParamName+'(5i)']
       updatedValueSecond = inParams[baseParamName+'(5i)']    
       updateValue = Time.zone.local(updatedValueYear.to_i,updatedValueMon.to_i,updatedValueDay.to_i,updatedValueHour.to_i,updatedValueMinute.to_i,updatedValueSecond.to_i)
       return updateValue
  end
end
