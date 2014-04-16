class EquipmentNeed < ActiveRecord::Base
  attr_accessible :lock_version, :programme_item_id, :equipment_type_id
  belongs_to :programme_item
  belongs_to :equipment_type
end
