class Event < ActiveRecord::Base
  validates_presence_of :title
  has_many  :event_assignments
  has_many  :people, :through => :event_assignments
  
  has_one   :room

end
