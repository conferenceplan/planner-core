class ProgrammeItemAssignment < ActiveRecord::Base  
  belongs_to  :person
  belongs_to  :programmeItem, :foreign_key => "programme_item_id"
  
  audited :associated_with => :person, :allow_mass_assignment => true

  has_enumerated :role, :class_name => 'PersonItemRole'

end
