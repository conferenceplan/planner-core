class CreateRoomSetups < ActiveRecord::Migration
  def self.up
    create_table :room_setups do |t|
      t.references :room
      t.references :setup_type
      t.integer :capacity

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :room_setups
  end
end
