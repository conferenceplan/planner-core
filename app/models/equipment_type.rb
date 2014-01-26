class EquipmentType < ActiveRecord::Base

  has_many :equipment_needs
  has_many :programme_items, :through => :equipment_needs

end
