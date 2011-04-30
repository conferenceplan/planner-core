class CreatePublishedRoomItemAssignments < ActiveRecord::Migration
  def self.up
    create_table :published_room_item_assignments do |t|
      t.references :published_room
      t.references :published_programme_item
      t.references :published_time_slot
      t.integer :day, { :default => -1 }

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :published_room_item_assignments
  end
end
