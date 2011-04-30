class CreatePublishedVenues < ActiveRecord::Migration
  def self.up
    create_table :published_venues do |t|
      t.text :name

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :published_venues
  end
end
