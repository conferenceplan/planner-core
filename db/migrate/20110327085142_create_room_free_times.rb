class CreateRoomFreeTimes < ActiveRecord::Migration
  def self.up
    create_table :room_free_times do |t|

      t.references :room
      t.references :time_slot

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :room_free_times
  end
end
