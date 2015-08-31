
json.total @total

json.rows @items do |item|

    json.id                 item.id
    json.title               item.title

end
