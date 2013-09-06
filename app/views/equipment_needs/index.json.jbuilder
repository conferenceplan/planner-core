
json.array!(@equipmentNeeds) do |json, equipment|
    json.id equipment.id
    json.equipment_type_id equipment.equipment_type.id
    json.equipment_type_name equipment.equipment_type.description
    json.programme_item_id equipment.programme_item.id
    json.lock_version equipment.lock_version
end
