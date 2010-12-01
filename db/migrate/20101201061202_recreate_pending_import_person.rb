class RecreatePendingImportPerson < ActiveRecord::Migration
  def self.up
      drop_table :pending_import_people
      create_table :pending_import_people do |t|
      t.string :first_name, { :default => "" }
      t.string :last_name, { :default => "" }
      t.string :suffix, { :default => "" }
      t.string :line1
      t.string :line2
      t.string :line3 
      t.string :city
      t.string :state
      t.string :postcode
      t.string :country, {:limit =>2} #use the ISO country code (put in seperate table the code to country names)
      t.string :phone
      t.string :email, { :default => "" }
      t.string :registration_number
      t.string :registration_type # TODO: place holder, change this to an actual type
    
      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
  end
  
end
