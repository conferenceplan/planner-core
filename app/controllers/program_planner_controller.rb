class ProgramPlannerController < PlannerController
  include ProgramPlannerHelper
  
  #
  #
  #
  def assignments
    @day = params[:day] # Day
    @roomListing = Room.all(:order => 'venues.name DESC, rooms.name ASC', :joins => :venue) #, :conditions => conditions) 
    @currentDate = Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + @day.to_i.day
  end
  
  #
  # Add an item to a room
  #
  def addItem
    @assignment = nil
    if !params[:cancel]
      item = ProgrammeItem.find(params[:itemid])
      room = Room.find(params[:roomid])
      day = params[:day]
      time = params[:time].to_time # The start time
    
      @assignment = addItemToRoomAndTimeNN(item, room, day, time)
    end

    render :layout => 'content'
  end
  
  #
  # Unschedule an item
  #
  def removeItem
    item = ProgrammeItem.find(params[:itemid])

    removeAssignment(item.room_item_assignment)
    
    render status: :ok, text: {}.to_json
  end
  
  #
  #
  #
  def getConflicts
    @day = params[:day]

    @conflicts = ProgramItemsService.getItemConflicts(@day)
    @roomConflicts = ProgramItemsService.getRoomConflicts(@day)
    @excludedItemConflicts = ProgramItemsService.getExcludedItemConflicts(@day)
    @excludedTimeConflicts = ProgramItemsService.getExcludedTimeConflicts(@day)
    @availableTimeConflicts = ProgramItemsService.getAvailabilityConficts(@day)
    @backtobackConflicts = ProgramItemsService.getBackToBackConflicts(@day)
  end

end
