class CreatePendingImportPeople < ActiveRecord::Migration
  def self.up
      create_table :pending_import_people do |t|
      t.string :first_name, { :default => "" }
      t.string :last_name, { :default => "" }
      t.string :suffix, { :default => "" }
      t.string :line1, {:default => ""}
      t.string :line2, {:default => ""}
      t.string :line3, {:default => ""}
      t.string :city, {:default =>""}
      t.string :state, {:default => ""}     # state, province, county...
      t.string :postcode, {:default => ""}  # zip, postal code ...
      t.string :country, {:limit =>2,:default => ""} #use the ISO country code (put in seperate table the code to country names)
      t.string :phone, {:default => ""}
      t.string :email, { :default => "" }
      t.string :registration_number, {:default => ""}
      t.string :registration_type, {:default => ""} # TODO: place holder, change this to an actual type
    
      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :pending_import_people
  end
end

