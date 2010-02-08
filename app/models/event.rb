class Event < ActiveRecord::Base

  has_many  :event_assignments
  has_many  :people, :through => :event_assignments
  
  has_one   :room

end
