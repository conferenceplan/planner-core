class RegistrationDetail < ActiveRecord::Base
  attr_accessible :lock_version, :registration_number, :registration_type, :registered, :person_id, :can_share
  
  belongs_to  :person 
  
  audited :associated_with => :person, :allow_mass_assignment => true

end
