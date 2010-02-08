class CreateExclusions < ActiveRecord::Migration
  def self.up
    create_table :exclusions do |t|

      t.column :excludable_id, :integer
      t.column :excludable_type, :string
      
      t.column :person_id, :integer

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :exclusions
  end
end
