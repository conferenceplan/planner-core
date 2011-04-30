#
#
#
class Published::ProgrammeItemAssignment < ActiveRecord::Base
  has_one  :person
  belongs_to  :programmeItem, :class_name => 'Published::ProgrammeItem', :foreign_key => "published_programme_item_id"

  has_enumerated :role, :class_name => 'PersonItemRole'
end
