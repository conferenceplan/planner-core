class CreateEventAssignments < ActiveRecord::Migration
  def self.up
    create_table :event_assignments do |t|
      
      t.integer :person_id
      t.integer :event_id
      t.string :role #TODO - change to a type
      
      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :event_assignments
  end
end
