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
json.visibility_id     item.visibility_id
json.visibility_name   item.visibility_name
json.duration               item.duration
json.maximum_people         item.maximum_people
json.minimum_people         item.minimum_people
json.setup_type_id          item.setup_type_id
json.setup_name             item.setup_type ? item.setup_type.name : "" 
json.format_id              item.format_id if item.format
json.format_name            item.format ? item.format.name : ""
json.start_offset           item.start_offset || 0

json.is_published           item.published ? true : false
json.is_break               item.is_break

json.published_item do
    if item.published
        json.partial! 'published_programme_items/published_programme_item', item: item.published
    end
end

json.start_day              item.room_item_assignment ? item.room_item_assignment.day : "" # we want this to be the number

json.start_time             item.start_time.present? ? item.start_time : ""
json.end_time             item.end_time.present? ? item.end_time : ""
json.start_day_str          item.start_time.present? ? item.start_time.strftime('%a, %b %d') : "" # we want this to be the number
json.start_time_str         item.start_time.present? ? item.start_time.strftime('%H:%M') : ""

json.audience_size          item.audience_size
json.mobile_card_size       item.mobile_card_size

json.external_images    item.external_images

# TODO - do we want just the name or do we want the actual id or entity?
json.room                   item.room ? item.room.name : ""
json.room_id                item.room ? item.room.id : ""
json.venue                  item.room && item.room.venue ? item.room.venue.name : ""
json.venue_id               item.room && item.room.venue ? item.room.venue.id : ""
    
json.lock_version           item.lock_version

json.parent_id              item.parent_id
json.parent_val do
    if item.parent
        json.partial! 'base_item', item: item.parent, role: nil
    end
end

json.theme_name_ids item.theme_names.collect{|c| c.id}

json.theme_names do
    json.array! item.theme_names do |n|
        json.id     n.id
        json.name   n.name
    end
end

json.published item.published.present?

default_person_img = default_person_img || DefaultBioImage.first

# TODO - do we want to list the participants?
if moderators
    json.moderators do
        json.array! moderators do |p|
            json.partial! 'person', person: p.person, type: 'moderator', default_img: default_person_img
        end
    end
end
if participants
    json.participants do
        json.array! participants do |p|
            json.partial! 'person', person: p.person, type: 'participant', default_img: default_person_img
        end
    end
end
if reserves
    json.reserves do
        json.array! reserves do |p|
            json.partial! 'person', person: p.person, type: 'reserved', default_img: default_person_img
        end
    end
end
if invisibles
    json.invisibles do
        json.array! invisibles do |p|
            json.partial! 'person', person: p.person, type: 'invisible', default_img: default_person_img
        end
    end
end

if @extra_item_json
    @extra_item_json.each do |extra|
        json.partial! extra, item: item
    end
end
