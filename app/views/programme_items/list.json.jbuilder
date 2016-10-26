
json.total @total

json.rows @items do |item|

    json.id                  item.id
    json.title               item.title
    json.start_time          item.start_time
    json.start_time_str      (item.start_time.present? ? Time.zone.parse((item.start_time).to_s).strftime('%m/%d/%Y %H:%M:%S') : "")
    json.end_time            item.end_time
    json.end_time_str        (item.end_time.present? ? Time.zone.parse((item.end_time).to_s).strftime('%m/%d/%Y %H:%M:%S') : "")
    json.date_time_str       ( item.start_time.present? ? 
        ' [' + l(item.start_time, format: :start_time_with_date) + " - " + l(item.end_time, format: :end_time) + ']' 
        : ""
    )

end
