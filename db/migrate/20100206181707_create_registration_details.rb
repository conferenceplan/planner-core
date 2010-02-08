class CreateRegistrationDetails < ActiveRecord::Migration
  def self.up
    create_table :registration_details do |t|
      t.references :Person # there is one registration detail per person
      
      t.string  :registration_number
      t.string  :registration_type # TODO: place holder, change this to an actual type
      t.boolean :registered # Question: is this redundant, if they are registered then them will have a reg number?
      t.boolean :ghost #if person might be coming and you want to schedule them, but not have them show up in any public reports
      
      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :registration_details
  end
end
