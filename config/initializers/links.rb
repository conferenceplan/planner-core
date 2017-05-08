#
#
#
require 'planner/linkable'

ActiveSupport.on_load(:programme_item) do
  Planner::Linkable.configure do |config|
    config.addLinkable ProgrammeItem
    ProgrammeItem.linked
  end
end
ActiveSupport.on_load(:published_programme_item) do
  Planner::Linkable.configure do |config|
    config.addLinkable PublishedProgrammeItem
    PublishedProgrammeItem.linked
  end
end
Planner::Linkable.configure do |config|
  config.addLinkable [Person, Venue, Room]
end
