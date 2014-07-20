class ProgramPlannerController < PlannerController
  include ProgramPlannerHelper
  
  #
  #
  #
  def assignments
    rooms = params[:rooms] ? params[:rooms].split(',').collect{|a| a.to_i} : nil
    @day = params[:day] # Day
    if rooms
      @roomListing = Room.all :order => 'venues.name DESC, rooms.name ASC',
                            :conditions => ["rooms.id in (?)", rooms],
                            :joins => :venue
    else  
      @roomListing = Room.all :order => 'venues.name DESC, rooms.name ASC',
                            :joins => :venue
    end
    site_config = SiteConfig.first
    @currentDate = Time.zone.parse(site_config.start_date.to_s) + @day.to_i.day
  end
  
  #
  # Add an item to a room
  #
  def addItem
    begin
      @assignment = nil
      if !params[:cancel]
        item = ProgrammeItem.find(params[:itemid])
        room = Room.find(params[:roomid])
        day = params[:day]
        time = params[:time].to_time # The start time
      
        @assignment = addItemToRoomAndTime(item, room, day, time)
      end
  
      render :layout => 'content'
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end
  
  #
  # Unschedule an item
  #
  def removeItem
    begin
      item = ProgrammeItem.find(params[:itemid])
  
      removeAssignment(item.room_item_assignment)
      
      render status: :ok, text: {}.to_json
    rescue => ex
      render status: :bad_request, text: ex.message
    end
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
