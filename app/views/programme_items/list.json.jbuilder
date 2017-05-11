
json.total @total

json.rows @items do |item|

    json.id                  item.id
    json.title               item.title
    json.start_time          item.start_time
    json.start_time_str      (item.start_time.present? ? Time.zone.parse((item.start_time).to_s).strftime('%m/%d/%Y %H:%M:%S') : "")
    json.end_time            item.end_time
    json.end_time_str        (item.end_time.present? ? Time.zone.parse((item.end_time).to_s).strftime('%m/%d/%Y %H:%M:%S') : "")
    json.date_time_str       ( item.start_time.present? ? 
        l(item.start_time, format: :start_time_with_date) + " - " + l(item.end_time, format: :end_time) 
        : ""
    )

    json.room item.room
    json.venue item.room.present? ? item.room.venue : nil

    json.num_assigned_participants item.programme_item_assignments.count
    json.min_people item.minimum_people
    json.max_people item.maximum_people
    json.visibility_id     item.visibility_id
    json.visibility_name   item.visibility_name

end
