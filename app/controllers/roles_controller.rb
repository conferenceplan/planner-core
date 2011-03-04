class RolesController < PlannerController
    layout "content"
    
  def list
    # Get all the roles in the database
    @roles = Role.find :all
  end

end
