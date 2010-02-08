class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string :line1
      t.string :line2
      t.string :line3
      t.string :city
      t.string :state     # state, province, county...
      t.string :postcode  # zip, postal code ...
      t.string :country, :limit =>2 #use the ISO country code (put in seperate table the code to country names)
      t.string :phone
      
      t.boolean :isvalid
      
      t.column :addressable_id, :integer
      t.column :addressable_type, :string     

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :addresses
  end
end
