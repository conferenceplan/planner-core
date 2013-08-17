
json.array!(@phoneNumbers) do |json, number|
    json.id number.id
    json.number number.number
    json.phone_type_id number.phone_type.id
    json.phone_type_name number.phone_type.name
    json.lock_version number.lock_version
end
