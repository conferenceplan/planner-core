#
#
#
class Published::ProgrammeItemAssignment < ActiveRecord::Base
  acts_as_audited

  has_one  :person
  belongs_to  :programmeItem, :class_name => 'Published::ProgrammeItem', :foreign_key => "published_programme_item_id"

  has_enumerated :role, :class_name => 'PersonItemRole'
end
