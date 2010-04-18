class Person < ActiveRecord::Base
  
  validates_uniqueness_of :last_name, :scope => [:first_name], :case_sensitive => false, :message => ':that person already exists in the database.' 
  
  has_many  :addresses, :as => :addressable, :dependent => :destroy # if two people can share the same address then the dependent destroy should be removed
  
  has_many  :relationships, :as => :relatable
  
  has_many  :related_people, :source_type => "Person", :through => :relationships

  has_many  :exclusions, :as => :excludable
  
  has_many  :excluded_people, :through => :exclusions, 
            :source => :person,
            :conditions => "exclusions.excludable_type = 'Person'"
  
  has_many  :excluded_periods, :through => :exclusions,
            :source => :period,
            :conditions => "exclusions.excludable_type = 'Period'"
  
  has_many  :excluded_events, :through => :exclusions,
            :source => :event,
            :conditions => "exclusions.excludable_type = 'Event'"
  
  has_many  :event_assignments
  has_many  :events, :through => :event_assignments

  has_one   :RegistrationDetail
  has_one   :Survey
  
end
