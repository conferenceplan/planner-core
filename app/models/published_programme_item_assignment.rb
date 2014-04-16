#
#
#
class PublishedProgrammeItemAssignment < ActiveRecord::Base
  attr_accessible :lock_version, :person, :role, :published_programme_item_id
  
  audited :allow_mass_assignment => true

  belongs_to  :person
  belongs_to  :published_programme_item, :foreign_key => "published_programme_item_id"

  has_enumerated :role, :class_name => 'PersonItemRole'
end
