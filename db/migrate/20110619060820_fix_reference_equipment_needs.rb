class FixReferenceEquipmentNeeds < ActiveRecord::Migration
  def self.up
     add_column :equipment_needs, :programme_item_id, :integer
     add_column :equipment_needs, :equipment_type_id, :integer
     add_column :equipment_needs, :lock_version, :integer, { :default => 0 }

  end

  def self.down
    remove_column :equipment_needs, :programme_item_id
    remove_column :equipment_needs, :equipment_type_id
    remove_column :equipoment_needs, :lock_version
  end
end
