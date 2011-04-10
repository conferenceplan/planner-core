class FixProgrammeItemRoomAndTimeRelation < ActiveRecord::Migration
  def self.up
      remove_column :rooms, :room_id
      remove_column :rooms, :time_slot_id
  end

  def self.down
  end
end
