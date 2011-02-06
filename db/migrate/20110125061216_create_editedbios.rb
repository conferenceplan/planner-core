class CreateEditedbios < ActiveRecord::Migration
 def self.up
    create_table :edited_bios do |t|
      t.text :bio
      
      t.references :person # The person that this is a bio for
      
      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :edited_bios
  end
end
