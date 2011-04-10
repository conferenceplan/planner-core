class ProgramPlannerController < PlannerController
  def index
  end
  
  #
  # Get the rooms and times for a given day
  # order by room and time
  #
  def list
    # Day
    day = params[:day]
    clause = addClause(nil, 'day = ?', day)

    # We need to know which rooms we are going for...
    args = { :conditions => clause }
    args.merge!(:joins => 'LEFT JOIN time_slots ON time_slots.id = time_slot_id LEFT JOIN rooms ON rooms.id = room_id')
    args.merge!(:order => 'rooms.id, time_slots.start')

    @roomAssignments = RoomItemAssignment.find :all, args
    
    @roomListing = Room.all(:order => 'rooms.id')

    respond_to do |format|
      format.html { render :layout => 'content' } # list.html.erb
      format.xml
    end
  end
  
end
