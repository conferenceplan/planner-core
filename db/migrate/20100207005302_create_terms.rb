class CreateTerms < ActiveRecord::Migration
  def self.up
    create_table :terms do |t|
      
      t.string :name
      t.text :description

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :terms
  end
end
