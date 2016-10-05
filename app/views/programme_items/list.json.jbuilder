
json.total @total

json.rows @items do |item|

    json.id                  item.id
    json.title               item.title
    json.start_time          item.start_time
    json.end_time            item.end_time

end
