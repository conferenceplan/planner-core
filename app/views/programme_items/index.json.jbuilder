
json.array!(@programmeItems) do |json, item|
    json.id item.id
    json.lock_version item.lock_version
    json.title item.title
    json.short_title item.short_title
    json.precis item.precis
    json.duration item.duration
    json.format_id item.format.id if item.format
    json.format_name item.format.name if item.format
    json.maximum_people item.maximum_people
    json.minimum_people item.minimum_people
    json.notes item.notes
    json.print item.print
    json.pub_reference_number item.pub_reference_number
    json.isPublished item.published != nil
    json.time_slot item.time_slot
    json.setup_type_id item.setup_type.id if item.setup_type
    json.setup_type_name item.setup_type.name if item.setup_type
end
