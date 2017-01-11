class RolesController < PlannerController
  layout "plain"
    
  def list
    # Get all the roles in the database
    @roles = Role.all
  end

end
