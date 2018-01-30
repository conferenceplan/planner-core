
json.total @total

json.rows @items do |item|

    json.id                  item.id
    json.title               item.title
    json.start_time          item.start_time
    json.start_time_str      (item.start_time.present? ? Time.zone.parse((item.start_time).to_s).strftime('%m/%d/%Y %H:%M:%S') : "")
    json.end_time            item.end_time
    json.end_time_str        (item.end_time.present? ? Time.zone.parse((item.end_time).to_s).strftime('%m/%d/%Y %H:%M:%S') : "")
    if item.start_time.present?
        multi_day = item.start_time.day != item.end_time.day
        end_format = multi_day ? :start_time_with_date : :end_time

        json.date_time_str l(item.start_time, format: :start_time_with_date) + " - " + l(item.end_time, format: end_format)
    else
        json.date_time_str ''
    end

    room = item.room
    if room
      json.room do
        json.id room.id
        json.name room.name
        json.lock_version room.lock_version
        json.venue_id room.venue_id
        json.purpose room.purpose
        json.comment room.comment
        json.setup_id room.setup_id
        json.base_room_id room.base_room_id
        json.sort_order room.sort_order
      end

      venue = room.venue
      json.venue do
        json.id venue.id
        json.name venue.name
        json.lock_version venue.lock_version
        json.base_venue_id venue.base_venue_id
        json.sort_order venue.sort_order
      end
    else
      json.room nil
      json.venue nil
    end

    json.num_assigned_participants item.programme_item_assignments.size
    json.min_people item.minimum_people
    json.max_people item.maximum_people
    json.visibility_id     item.visibility_id
    json.visibility_name   item.visibility_name

end
