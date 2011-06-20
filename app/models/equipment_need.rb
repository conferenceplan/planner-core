class EquipmentNeed < ActiveRecord::Base
  belongs_to :programme_item
  belongs_to :equipment_type
end
