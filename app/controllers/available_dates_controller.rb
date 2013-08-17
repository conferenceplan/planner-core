class AvailableDatesController < PlannerController
  
  def update
    availableDate = AvailableDate.find(params[:id])
    availableDate.update_attributes(params[:available_date])
    render json: availableDate.to_json, :content_type => 'application/json'
  end
  
  def create
    if (params[:person_id])
      person = Person.find(params[:person_id])
      availableDate = person.create_available_date(updateParams);
      availableDate.update_attributes(params[:available_date])
    else
      availableDate = AvailableDates.new(params[:available_date])
    end
    
    availableDate.save
    
    render json: availableDate.to_json, :content_type => 'application/json'
  end

  def show
    if (params[:person_id])
       person = Person.find(params[:person_id])
       availableDate = person.available_date
    else
      availableDate = AvailableDate.find(params[:id])
    end
    
    render json: availableDate.to_json, :content_type => 'application/json'
  end

  def destroy
    availableDate = AvailableDate.find(params[:id])
    availableDate.destroy
    render text: 'OK'
  end

  def index
    # TODO - to be checked
    availableDates = AvailableDate.find :all
    render json: availableDates.to_json, :content_type => 'application/json'
  end

  # TODO - this can move to the view where we input the dates  
  def GetDefaultStart
    return Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + 12.hours
  end
  
  def GetDefaultEnd
    return Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + (SITE_CONFIG[:conference][:number_of_days]-1).days + 16.hours;
  end

  # TODO - check where this is used 
  # def GetDateFromInput(inParams,baseParamName)
       # updatedValueYear = inParams[baseParamName+'(1i)']
       # updatedValueMon = inParams[baseParamName+'(2i)']
       # updatedValueDay = inParams[baseParamName+'(3i)']
       # updatedValueHour = inParams[baseParamName+'(4i)']
       # updatedValueMinute = inParams[baseParamName+'(5i)']
       # updatedValueSecond = inParams[baseParamName+'(5i)']    
       # updateValue = Time.zone.local(updatedValueYear.to_i,updatedValueMon.to_i,updatedValueDay.to_i,updatedValueHour.to_i,updatedValueMinute.to_i,updatedValueSecond.to_i)
       # return updateValue
  # end
end
