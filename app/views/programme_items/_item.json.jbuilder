#
#
#

json.id                     item.id    
json.title                  item.title    
json.short_title            item.short_title
json.precis                 item.precis
json.short_precis           item.short_precis
json.item_notes             item.item_notes
json.participant_notes      item.participant_notes
json.pub_reference_number   item.pub_reference_number
json.print                  item.print
json.duration               item.duration
json.maximum_people         item.maximum_people
json.minimum_people         item.minimum_people
json.setup_type_id          item.setup_type_id
json.setup_name             item.setup_type ? item.setup_type.name : "" 
json.format_id              item.format_id if item.format
json.format_name            item.format ? item.format.name : ""

json.is_published           item.published ? true : false
json.is_break               item.is_break

json.start_day              item.room_item_assignment ? item.room_item_assignment.day : "" # we want this to be the number
json.start_day_str          item.time_slot ? item.time_slot.start.strftime('%A') : "" # we want this to be the number
json.start_time             item.time_slot ? item.time_slot.start : ""
json.start_time_str         item.time_slot ? item.time_slot.start.strftime('%H:%M') : ""
json.audience_size          item.audience_size
json.mobile_card_size       item.mobile_card_size

json.external_images    item.external_images

# TODO - do we want just the name or do we want the actual id or entity?
json.room                   item.room ? item.room.name : ""
json.room_id                item.room ? item.room.id : ""
    
json.lock_version           item.lock_version

json.parent_id              item.parent_id
json.parent_val do
    if item.parent
        json.id     item.parent.id
        json.title   item.parent.title
    end
end

json.theme_name_ids item.theme_names.collect{|c| c.id}

json.theme_names do
    json.array! item.theme_names do |n|
        json.id     n.id
        json.name   n.name
    end
end


# TODO - do we want to list the participants?
if moderators
    json.moderators do
        json.array! moderators do |p|
            json.partial! 'person', person: p.person
        end
    end
end
if participants
    json.participants do
        json.array! participants do |p|
            json.partial! 'person', person: p.person
        end
    end
end
if reserves
    json.reserves do
        json.array! reserves do |p|
            json.partial! 'person', person: p.person
        end
    end
end
if invisibles
    json.invisibles do
        json.array! invisibles do |p|
            json.partial! 'person', person: p.person
        end
    end
end

@extra_item_json.each do |extra|
    json.partial! extra, item: item
end
