#
#
#
class PublishedProgrammeItemAssignment < ActiveRecord::Base
  attr_accessible :lock_version, :person, :role, :published_programme_item_id, :person_name, :sort_order, :description
  
  audited :allow_mass_assignment => true

  include RankedModel
  ranks :sort_order, :with_same => [:published_programme_item_id, :role_id]

  belongs_to  :person
  belongs_to  :published_programme_item, :foreign_key => "published_programme_item_id"

  has_enumerated :role, :class_name => 'PersonItemRole'

  def time_stamp
    updated_at.utc
  end

  def role_as_string
    if description.present?
      description
    else
      PersonItemRole.find(role_id).name
    end
  end

  def person_role
    role_as_string
  end

end
