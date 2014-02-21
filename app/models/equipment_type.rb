class EquipmentType < ActiveRecord::Base

  has_many :equipment_needs
  has_many :programme_items, :through => :equipment_needs

  before_destroy :check_for_use

private

  def check_for_use
    if EquipmentNeed.where( :equipment_type_id => id ).exists?
      raise "can not delete an equipment type that is being used"
    end
  end

end

