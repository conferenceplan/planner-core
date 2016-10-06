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
json.start_offset           item.start_offset

json.is_published           item.published ? true : false
json.is_break               item.is_break

json.start_day              item.room_item_assignment ? item.room_item_assignment.day : "" # we want this to be the number

json.start_time             item.start_time.present? ? item.start_time : ""
json.end_time             item.end_time.present? ? item.end_time : ""
json.start_day_str          item.start_time.present? ? item.start_time.strftime('%A') : "" # we want this to be the number
json.start_time_str         item.start_time.present? ? item.start_time.strftime('%H:%M') : ""

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
        json.start_time   item.parent.start_time
        json.start_time_str   Time.zone.parse((item.parent.start_time).to_s).strftime('%m/%d/%Y %H:%M:%S')
        json.end_time   item.parent.end_time
        json.end_time_str        Time.zone.parse((item.parent.end_time).to_s).strftime('%m/%d/%Y %H:%M:%S')
        json.date_time_str       ( item.parent.start_time.present? ? 
        ' [' + l(item.start_time, format: :start_time_with_date) + " - " + l(item.end_time, format: :end_time) + ']' 
        : "")
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
