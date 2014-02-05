
json.array!(@allTagCounts) do |json, context|
    json.context context[0]
    json.tags context[1]
end
