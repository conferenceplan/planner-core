class CreatePersonMailingAssignments < ActiveRecord::Migration
  def self.up
    create_table :person_mailing_assignments do |t|
      
      t.integer   "person_id"        # Person
      t.integer   "mailing_id"       # Mailing

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :person_mailing_assignments
  end
end
