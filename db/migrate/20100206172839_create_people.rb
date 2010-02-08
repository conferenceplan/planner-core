class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.string :first_name, { :default => "" }
      t.string :last_name, { :default => "" }
      t.string :suffix, { :default => "" }
      t.string :email, { :default => "" } # TODO - perhaps the email should be in contact information or address...
      
      # TODO: do we need badge and publication names?
      t.string :language, { :default => "" }# use two character country code for preferred language

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :people
  end
end
