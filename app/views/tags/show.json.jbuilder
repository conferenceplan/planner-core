
json.array!(@allTags.sort_by{|name, tags| name.downcase }) do |context|
    json.obj_id @personId
    json.context context[0]
    json.tags context[1]
end
