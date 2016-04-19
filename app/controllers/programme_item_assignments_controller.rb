class ProgrammeItemAssignmentsController < PlannerController

  #
  #
  #  
  def index
    where_part = {}
    where_part[:programme_item_id]  = params[:item_id] if params[:item_id]
    where_part[:role_id]  = params[:role_id] if params[:role_id]
    
    @programme_item_assignments = ProgrammeItemAssignment.where(where_part)
  end

  #
  #
  #  
  def update
    item = ProgrammeItem.find(params[:item_id])
    _assignments = params[:programme_item_assignments] # json rep of the assignments to update etc
    assignments = []
    if _assignments
      assignments = _assignments.map{|a|
          assignment = nil
          # venue.sort_order_position = params[:venue_order_position]
          if (a["id"])
            assignment = ProgrammeItemAssignment.find(a["id"])
            assignment.update_attributes a.delete_if{|e| ["role_name", "person_name", "item_title", "sort_order_position"].include? e}
          else
            assignment = ProgrammeItemAssignment.new(a.delete_if{|e| ["role_name", "person_name", "item_title", "sort_order_position"].include? e})
          end
          assignment.sort_order = a["sort_order_position"]
          assignment.sort_order_position = a["sort_order_position"]
          assignment
        }
    end
    
    item.update_assignments assignments #, role_id
    item.reload

    @programme_item_assignments = item.programme_item_assignments.includes({:person => :pseudonym})

  rescue => ex
    render status: :bad_request, text: ex.message
  end
  
  #
  #
  #  
  def destroy

    programme_item_assignment = ProgrammeItemAssignment.find params[:id]
    programme_item_assignment.destroy

  rescue => ex
    render status: :bad_request, text: ex.message
  end
  
end
