
json.array!(@allTagCounts) do |context|
    json.context context[0]
    json.tags context[1]
end
