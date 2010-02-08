class CreateRooms < ActiveRecord::Migration
  def self.up
    create_table :rooms do |t|

      t.references :venue

      t.text :string
      t.integer :capacity # what if capacity changes depending on layout?

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :rooms
  end
end
