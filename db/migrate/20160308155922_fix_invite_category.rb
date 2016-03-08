require 'person'
require 'person_con_state'
require 'invitation_category'

class FixInviteCategory < ActiveRecord::Migration
  def up
    # move the invite status id to the :person_con_states
    # Migrate the state data for people to the new table (note we keep the old data for now)
    people = Person.all
    people.each do |person|
      invite_cat = person.dep_invitation_category
      if invite_cat
        states = PersonConState.where({
          :person_id => person.id,
          :conference_id => invite_cat.conference_id
        }).first
        if !states
          states = PersonConState.new(person_id: person.id, invitestatus_id: person.invitestatus_id, acceptance_status_id: person.acceptance_status_id)
        end
        states.invitation_category_id = invite_cat.id
        states.save!
      end
    end
  end
end
