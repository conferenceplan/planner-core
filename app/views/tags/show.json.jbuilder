
json.array!(@allTags.sort_by{|name, tags| name.downcase }) do |json, context|
    json.person_id @personId
    json.context context[0]
    json.tags context[1]
end
