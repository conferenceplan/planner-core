#
#
#
class PublishedProgrammeItemAssignment < ActiveRecord::Base
  audited

  belongs_to  :person
  belongs_to  :published_programme_item, :foreign_key => "published_programme_item_id"

  has_enumerated :role, :class_name => 'PersonItemRole'
end
