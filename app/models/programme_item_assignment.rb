class ProgrammeItemAssignment < ActiveRecord::Base
  acts_as_audited
  
  belongs_to  :person
  belongs_to  :programmeItem, :foreign_key => "programme_item_id"
  
  acts_as_audited :parent => :person

  has_enumerated :role, :class_name => 'PersonItemRole'

end
