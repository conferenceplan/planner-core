
json.array!(@allTagCounts.sort_by{|name, tags| name.downcase }) do |json, context|
    json.context context[0]
    json.tags context[1]
end
