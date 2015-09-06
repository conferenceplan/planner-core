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
json.print                  item.print
json.pub_reference_number   item.pub_reference_number
json.isPublished            item.published != nil
json.start_time_str         item.time_slot ? item.time_slot.start.strftime('%A, %B %e %Y, %l:%M %P') : ""
json.time_slot              item.time_slot
json.room                   item.room
json.venue                  item.room.venue if item.room
json.setup_type_id          item.setup_type.id if item.setup_type
json.setup_type_name        item.setup_type.name if item.setup_type
json.role                   role if role
json.other_participants     item.programme_item_assignments.collect{|a| (a.person != @person && ![PersonItemRole['Invisible'], PersonItemRole['Reserved']].include?(a.role)) ? a.person.getFullPublicationName : nil }.compact
json.parent_id              item.parent_id

json.parent_val do
    if item.parent
        json.partial! 'base_item', item: item.parent, role: nil
    end
end
