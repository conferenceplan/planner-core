class CreateIndexesForConflictReports < ActiveRecord::Migration
  def self.up
    add_index :room_item_assignments, [:room_id], :name => 'ria_room_id_index'
    add_index :room_item_assignments, [:programme_item_id], :name => 'ria_prog_item_id_index'
    add_index :room_item_assignments, [:time_slot_id], :name => 'ria_time_slot_id_index'
    add_index :room_item_assignments, [:day], :name => 'ria_day_index'
    add_index :time_slots, [:start], :name => 'time_slot_start_index'
    add_index :time_slots, [:end], :name => 'time_slot_end_index'
    add_index :programme_item_assignments, [:person_id], :name => 'pia_person_index'
    add_index :programme_item_assignments, [:programme_item_id], :name => 'pis_prog_item_id_index'
    add_index :programme_item_assignments, [:role_id], :name => 'pia_role_id_index'
  end

  def self.down
    remove_index :room_item_assignments, :name => 'ria_room_id_index'
    remove_index :room_item_assignments, :name => 'ria_prog_item_id_index'
    remove_index :room_item_assignments, :name => 'ria_time_slot_id_index'
    remove_index :room_item_assignments, :name => 'ria_day_index'
    remove_index :time_slots, :name => 'time_slot_start_index'
    remove_index :time_slots, :name => 'time_slot_end_index'
    remove_index :programme_item_assignments, :name => 'pia_person_index'
    remove_index :programme_item_assignments, :name => 'pis_prog_item_id_index'
    remove_index :programme_item_assignments, :name => 'pia_role_id_index'
  end
end
