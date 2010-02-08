class CreateRelationships < ActiveRecord::Migration
  def self.up
    create_table :relationships do |t|
      
      t.column  :relatable_id, :integer
      t.column  :relatable_type, :string
      
      t.integer :person_id
      
      t.string  :relationship_type # what type of relationship (PA, partner etc) - TODO - move to an actual relationship type

      t.timestamps
      t.column  :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :relationships
  end
end
