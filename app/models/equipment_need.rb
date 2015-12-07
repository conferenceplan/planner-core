class EquipmentNeed < ActiveRecord::Base
  attr_accessible :lock_version, :programme_item_id, :equipment_type_id, :quantity
  belongs_to :programme_item
  belongs_to :equipment_type
  
  # Before save ensure that quantity is at least 1
  before_save :ensure_quantity

  def ensure_quantity
    self.quantity = 1 if self.quantity < 1
  end
end
