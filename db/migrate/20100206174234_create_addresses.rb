class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.column :addressable_id, :integer
      t.column :addressable_type, :string     

      t.column :person_id, :integer
      t.boolean :isvalid

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :addresses
  end
end
