class CreatePersonConStates < ActiveRecord::Migration
  def change
    create_table :person_con_states do |t|
      t.integer :person_id
      t.integer :acceptance_status_id
      t.integer :invitestatus_id

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end

    add_index :person_con_states, :person_id
    
    # Migrate the state data for people to the new table (note we keep the old data for now)
    people = Person.all
    people.each do |person|
      states = PersonConState.new(person_id: person.id, invitestatus_id: person.invitestatus_id, acceptance_status_id: person.acceptance_status_id)
      states.save!
    end
  end
end
