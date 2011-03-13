class ProgrammeItemAssignment < ActiveRecord::Base
  belongs_to  :person
  belongs_to  :programmeItem
  
  acts_as_audited :parent => :person

  has_enumerated :role, :class_name => 'PersonItemRole'

end
