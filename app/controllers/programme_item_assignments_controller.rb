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
    role_id = params[:role_id] if params[:role_id]
    assignments = params[:programme_item_assignments] # json rep of the assignments to update etc
    
    item.update_assignments assignments, role_id
    item.reload

    where_part = {}
    where_part[:role_id]  = params[:role_id] if params[:role_id]
    @programme_item_assignments = item.programme_item_assignments.
                                        includes({:person => :pseudonym}).
                                        where(where_part)
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
