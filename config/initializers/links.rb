#
#
#
require 'planner/linkable'

Planner::Linkable.configure do |config|
  config.addLinkable [Person, ProgrammeItem]
end
