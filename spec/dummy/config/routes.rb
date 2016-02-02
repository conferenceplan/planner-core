Dummy::Application.routes.draw do
  filter :locale
  mount PlannerCore::Engine => '/' #, as: 'planner_core'
end
