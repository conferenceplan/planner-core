class ProgrammeItemAssignment < ActiveRecord::Base  
  attr_accessible :lock_version, :person, :role, :programme_item_id
  
  belongs_to  :person
  belongs_to  :programmeItem, :foreign_key => "programme_item_id"
  
  audited :associated_with => :person, :allow_mass_assignment => true

  has_enumerated :role, :class_name => 'PersonItemRole'

end
