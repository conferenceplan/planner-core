
json.array!(@allTags) do |json, context|
    json.person_id @personId
    json.context context[0]
    json.tags context[1]
end
