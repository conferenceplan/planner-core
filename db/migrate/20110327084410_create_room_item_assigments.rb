class CreateRoomItemAssigments < ActiveRecord::Migration
  def self.up
    create_table :room_item_assigments do |t|

      t.references :room
      t.references :programme_item
      t.references :time_slot

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :room_item_assigments
  end
end
