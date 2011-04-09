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

#SELECT `room_item_assignments`.* FROM `room_item_assignments`
#LEFT JOIN time_slots ON time_slots.id = time_slot_id
#LEFT JOIN rooms  ON rooms.id = room_id
#WHERE (day = '0')
#ORDER BY rooms.id, time_slots.start
    # We need to know which rooms we are going for...
    args = { :conditions => clause }
    args.merge!(:joins => 'LEFT JOIN time_slots ON time_slots.id = time_slot_id LEFT JOIN rooms ON rooms.id = room_id')
    args.merge!(:order => 'rooms.id, time_slots.start')

    @roomAssignments = RoomItemAssignment.find :all, args
    
#    panels = ProgrammeItem.all(:include => :people,
#    :conditions => ["programme_items.updated_at >= ? or programme_item_assignments.updated_at >= ? or (programme_items.updated_at is NULL and programme_items.created_at >= ?) or (programme_item_assignments.updated_at is NULL and programme_item_assignments.created_at >= ?)", mod_date, mod_date, mod_date, mod_date],
#    :order => "programme_items.id, people.last_name") 
    @roomListing = Room.all(:order => 'rooms.id')

    # TODO - return the result as JSON so that the JS can parse it for the display
    respond_to do |format|
      format.html { render :layout => 'content' } # list.html.erb
      format.xml
    end
  end
  
end
