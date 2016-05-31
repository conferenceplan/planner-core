class ProgrammeItemAssignment < ActiveRecord::Base  
  attr_accessible :lock_version, :person, :person_id, :role, :role_id, :programme_item_id, :sort_order,
                  :id, :sort_order_position, :description

  include RankedModel
  ranks :sort_order, :with_same => [:programme_item_id, :role_id]
  default_scope order('programme_item_assignments.sort_order asc')
  
  belongs_to  :person
  belongs_to  :programmeItem, :foreign_key => "programme_item_id"
  
  audited :associated_with => :person, :allow_mass_assignment => true

  has_enumerated :role, :class_name => 'PersonItemRole'

end
