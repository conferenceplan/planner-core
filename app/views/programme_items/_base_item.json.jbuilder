json.id                     item.id
json.lock_version           item.lock_version
json.title                  item.title
json.short_title            item.short_title
json.precis                 item.precis
json.duration               item.duration
json.format_id              item.format.id if item.format
json.format_name            item.format.name if item.format
json.maximum_people         item.maximum_people
json.minimum_people         item.minimum_people
json.item_notes             item.item_notes
json.visibility_id     item.visibility_id
json.visibility_name   item.visibility_name
json.pub_reference_number   item.pub_reference_number
json.isPublished            item.published != nil
json.time_slot              item.time_slot
json.room                   item.room
json.venue                  item.room.venue if item.room
json.setup_type_id          item.setup_type.id if item.setup_type
json.setup_type_name        item.setup_type.name if item.setup_type
json.role                   role if role
json.other_participants     item.programme_item_assignments.collect{|a| (a.person != @person && ![PersonItemRole['Invisible'], PersonItemRole['Reserved']].include?(a.role)) ? a.person.getFullPublicationName : nil }.compact
json.parent_id              item.parent_id
json.is_break               item.is_break
json.start_offset           item.start_offset || 0
# json.start_time_str         item.time_slot ? item.time_slot.start.strftime('%A, %B %e %Y, %l:%M %P') : ""
json.start_time             item.start_time
json.start_time_str         (item.start_time.present? ? Time.zone.parse((item.start_time).to_s).strftime('%m/%d/%Y %H:%M:%S') : "")

json.end_time               item.end_time
json.end_time_str           (item.end_time.present? ? Time.zone.parse((item.end_time).to_s).strftime('%m/%d/%Y %H:%M:%S') : "")

if item.start_time.present?
    multi_day = item.start_time.day != item.end_time.day
    end_format = multi_day ? :start_time_with_date : :end_time

    json.date_time_str l(item.start_time, format: :start_time_with_date) + " - " + l(item.end_time, format: end_format)
else
    json.date_time_str ''
end

json.parent_val do
    if item.parent
        json.partial! 'base_item', item: item.parent, role: nil
    end
end
