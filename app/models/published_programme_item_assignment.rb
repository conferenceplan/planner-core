#
#
#
class PublishedProgrammeItemAssignment < ActiveRecord::Base
  acts_as_audited

  has_one  :person
  belongs_to  :published_programme_item, :foreign_key => "published_programme_item_id" #, :class_name => 'PublishedProgrammeItem'

  has_enumerated :role, :class_name => 'PersonItemRole'
end
