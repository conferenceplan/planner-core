require 'person'
require 'person_con_state'

class MigratePersonConStates < ActiveRecord::Migration
  def change
    # Migrate the state data for people to the new table (note we keep the old data for now)
    people = Person.all
    people.each do |person|
      states = PersonConState.new(person_id: person.id, invitestatus_id: person.invitestatus_id, acceptance_status_id: person.acceptance_status_id)
      states.save!
    end
  end
end
