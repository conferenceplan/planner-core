class CreatePseudonyms < ActiveRecord::Migration
  def self.up
    create_table :pseudonyms do |t|
      t.string :first_name, { :default => "" }
      t.string :last_name, { :default => "" }
      t.string :suffix, { :default => "" }

      t.references :Person # The person that this is a pseudonym for
      
      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :pseudonyms
  end
end
