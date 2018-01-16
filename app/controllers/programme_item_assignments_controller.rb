class ProgrammeItemAssignmentsController < PlannerController

  #
  #
  #  
  def index
    where_part = {}
    where_part[:programme_item_id]  = params[:item_id] if params[:item_id]
    where_part[:role_id]  = params[:role_id] if params[:role_id]
    
    @programme_item_assignments = ProgrammeItemAssignment.rank(:sort_order).where(where_part)
  end

  #
  #
  #
  def update
    ProgrammeItem.transaction do
      item = ProgrammeItem.find(params[:item_id])
      _assignments = params[:programme_item_assignments] # json rep of the assignments to update etc
      assignments = []
      if _assignments
        assignments = _assignments.map{|a|
          assignment = nil
          if (a["id"])
            assignment = ProgrammeItemAssignment.find(a["id"].to_i)
            assignment.update_attributes a.delete_if{|e| ["role_name", "person_name", "item_title"].include? e}
          else
            assignment = ProgrammeItemAssignment.new(a.delete_if{|e| ["role_name", "person_name", "item_title"].include? e})
          end

          assignment
        }
      end

      item.update_assignments assignments #, role_id
      item.reload

      @programme_item_assignments = item.programme_item_assignments.rank(:sort_order).includes({:person => :pseudonym})
    end
  rescue => ex
    render status: :bad_request, text: ex.message
  end
  
  #
  #
  #  
  def destroy

    programme_item_assignment = ProgrammeItemAssignment.find params[:id]
    programme_item_assignment.programmeItem.touch
    programme_item_assignment.programmeItem.save
    programme_item_assignment.destroy
    
    # need to touch the item

  rescue => ex
    render status: :bad_request, text: ex.message
  end
  
end
