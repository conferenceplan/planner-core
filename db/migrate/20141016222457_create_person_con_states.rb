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
  end
end
