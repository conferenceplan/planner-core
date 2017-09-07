require "enum"
require "visibility"

class ChangeNameOfSpeakerRoleEnum < ActiveRecord::Migration
  def up
    PersonItemRole.enumeration_model_updates_permitted = true
    role = PersonItemRole.find_by(name: 'Speaker')
    if role
      role.name = 'OtherParticipant'
      role.save!
    end
  end

  def down
    PersonItemRole.enumeration_model_updates_permitted = true
    role = PersonItemRole.find_by(name: 'OtherParticipant')
    if role
      role.name = 'Speaker'
      role.save!
    end
  end
end
