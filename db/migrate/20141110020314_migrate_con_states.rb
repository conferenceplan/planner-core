require 'person'
require 'person_con_state'

class MigrateConStates < ActiveRecord::Migration
  def change
    # Migrate the state data for people to the new table (note we keep the old data for now)
    people = Person.all
    people.each do |person|
      if !person.person_con_state
        person.person_con_state = PersonConState.new
        person.person_con_state.save!
      end
    end
  end
end
