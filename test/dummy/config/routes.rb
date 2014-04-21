Dummy::Application.routes.draw do

  mount PlannerCore::Engine => '/' #, as: 'planner_core'

end
