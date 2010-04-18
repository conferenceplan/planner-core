class Event < ActiveRecord::Base
  validates_presence_of :title
  has_many  :event_assignments
  has_many  :people, :through => :event_assignments
 
  # Add event substitutions, people that can be added to an event
  # if person is removed from event then user is asked if the person should be added to subs
  
  has_one   :room

end
