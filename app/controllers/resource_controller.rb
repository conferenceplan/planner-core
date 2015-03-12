#
#
#
class ResourceController < PlannerController

  before_filter :load_resource

  respond_to :json
  
  include Planner::Controllers::ResourceMethods

end