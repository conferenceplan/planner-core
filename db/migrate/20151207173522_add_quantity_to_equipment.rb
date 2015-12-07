class AddQuantityToEquipment < ActiveRecord::Migration
  def change
    add_column :equipment_needs, :quantity, :integer, {:default => 1}
  end
end
