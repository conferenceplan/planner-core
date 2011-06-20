class FixupEquipmentTables < ActiveRecord::Migration
  def self.up
     add_column :equipment_types, :lock_version, :integer, { :default => 0 }
     add_column :equipment, :lock_version, :integer, { :default => 0 }
     add_column :equipment_assignments, :lock_version, :integer, { :default => 0 }
     add_column :equipment_assignments, :programme_item_id, :integer
     add_column :equipment_assignments, :equipment_id, :integer
     add_column :equipment, :equipment_type_id, :integer
     add_column :equipment, :room_id, :integer
  end

  def self.down
     remove_column :equipment_types, :lock_version
     remove_column :equipment, :lock_version
     remove_column :equipment_assignments, :lock_version
     remove_column :equipment_assignments, :programme_item_id
     remove_column :equipment_assignments, :equipment_id
     remove_column :equipment, :equipment_type_id
     remove_column :equipment, :room_id
  end
end
