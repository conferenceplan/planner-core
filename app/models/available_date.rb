class AvailableDate < ActiveRecord::Base
  belongs_to  :person 

  audited :associated_with => :person, :allow_mass_assignment => true

end
