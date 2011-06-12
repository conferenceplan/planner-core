class CreateEquipment < ActiveRecord::Migration
  def self.up
    create_table :equipment do |t|
      t.Room :references
      t.EquipmentType :references
      t.string :details

      t.timestamps
    end
  end

  def self.down
    drop_table :equipment
  end
end
