class CreateVenues < ActiveRecord::Migration
  def self.up
    create_table :venues do |t|

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :venues
  end
end
