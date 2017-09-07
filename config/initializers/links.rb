#
#
#
require 'planner/linkable'

Planner::Linkable.configure do |config|
  config.addLinkable ["Person", "ProgrammeItem", "PublishedProgrammeItem", "Venue", "Room"]
end
