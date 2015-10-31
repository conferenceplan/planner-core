#
#
#
class PublishedProgrammeItemAssignment < ActiveRecord::Base
  attr_accessible :lock_version, :person, :role, :published_programme_item_id, :person_name
  
  audited :allow_mass_assignment => true

  belongs_to  :person
  belongs_to  :published_programme_item, :foreign_key => "published_programme_item_id"

  has_enumerated :role, :class_name => 'PersonItemRole'

  def time_stamp
    updated_at.utc
  end
  
  def role_as_string
    PersonItemRole.find(role_id).name
  end

  def serializable_hash(options = {})
    super only: [], methods: [:time_stamp, :role_as_string], include: {
          published_programme_item: {
              only: [:id]
          }
        }
  end

end
