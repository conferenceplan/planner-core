class ProgramPlannerController < PlannerController
  include ProgramPlannerHelper
  
  def index
  end

  def getRoomControl
    @roomListing = Room.all(:order => 'venues.name DESC, rooms.name ASC', :joins => :venue) 

    respond_to do |format|
      format.html { render :layout => 'plain' }
      format.xml
    end
  end
  
  #
  # Get the rooms and times for a given day
  # order by room and time
  #
  def list
    rooms = ActiveSupport::JSON.decode params[:rooms] if params[:rooms] # the rooms that we want to show
    conditions = ['rooms.id in (?)', rooms] if rooms && (rooms.size > 0)
    @day = params[:day] # Day
    @roomListing = Room.all(:order => 'venues.name DESC, rooms.name ASC', :joins => :venue, :conditions => conditions) # use room_item_assignments.day(@day) to filter list of assignments by day
    
    @currentDate = Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + @day.to_i.day
    
    respond_to do |format|
      format.html { render :layout => 'content' } # list.html.erb
      format.xml
    end
  end
  
  def edit
    @day = params[:day]
    @item = ProgrammeItem.find(params[:itemid])
    @room = Room.find(params[:id])
    
    render :layout => 'content'
  end
  
  #
  # Add an item to a room
  #
  def addItem
    if !params[:cancel]
      @item = ProgrammeItem.find(params[:itemid])
      @room = Room.find(params[:roomid])
      @day = params[:day]
      time = params[:time] # The start time in hours and minutes for the programme item
    
      addItemToRoomAndTime(@item, @room, @day, time)
    end
        
    render :layout => 'content'
  end
  
  #
  # Unschedule an item
  #
  def removeItem
    @item = ProgrammeItem.find(params[:itemid])
    @room = Room.find(params[:roomid])

    removeAssignment(@item.room_item_assignment)
    
    render :layout => 'content'
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
    
    respond_to do |format|
      format.html { 
        if @day
          render :layout => 'plain'
        end
      }
    end
  end

end
