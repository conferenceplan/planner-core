class CreatePublishedRooms < ActiveRecord::Migration
  def self.up
    create_table :published_rooms do |t|
      t.references :published_venue
      t.text :name

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :published_rooms
  end
end
