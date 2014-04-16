class AvailableDate < ActiveRecord::Base
  attr_accessible :start_time, :end_time, :person_id, :lock_version
  belongs_to  :person 

  audited :associated_with => :person, :allow_mass_assignment => true

end
