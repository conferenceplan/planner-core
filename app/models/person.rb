class Person < ActiveRecord::Base
  
  validates_uniqueness_of :last_name, :scope => [:first_name], :case_sensitive => false, :message => ':that person already exists in the database.' 
  
  has_many  :addresses, :as => :addressable #, :dependent => :destroy # if two people can share the same address then the dependent destroy should be removed
  has_many  :postal_addresses, :through => :addressable,
            :source_type => "PostalAddress",
            :conditions => "addresses.addressable_type = 'PostalAddress'"
  has_many  :email_addresses, :through => :addressable,
            :source_type => "EmailAddress",
            :conditions => "addresses.addressable_type = 'EmailAddress'"
  
  has_many  :relationships, :as => :relatable
  
  has_many  :related_people, :source_type => "Person", :through => :relationships

  has_many  :exclusions, :as => :excludable
  
  has_many  :excluded_people, :through => :exclusions, 
            :source => :person,
            :conditions => "exclusions.excludable_type = 'Person'"
  
  has_many  :excluded_periods, :source_type => "Period", :through => :exclusions,
            :conditions => "exclusions.excludable_type = 'Period'"
  
  has_many  :excluded_items, :source_type => "ProgrammeItem", :through => :exclusions,
            :conditions => "exclusions.excludable_type = 'ProgrammeItem'"
  
  # TODO - check this
  has_many  :programmeItemAssignments
  has_many  :programmeItems, :through => :programmeItemAssignments

  has_one   :registrationDetail
  has_one   :survey
  
end
