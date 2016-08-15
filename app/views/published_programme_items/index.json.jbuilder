
json.array!(@published_programme_items) do |item|

    json.partial! 'published_programme_item', item: item

end
