class Pseudonym < ActiveRecord::Base
  attr_accessible :lock_version, :first_name, :last_name, :suffix, :person_id
  
  belongs_to  :person 
  
  audited :associated_with => :person, :allow_mass_assignment => true

end
