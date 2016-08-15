
json.id                 item.id
json.lock_version       item.lock_version    
json.updated_at         item.updated_at.utc
json.created_at         item.created_at.utc
json.title              item.title    
json.themes             item.theme_names.collect{|c| c.id}
json.format             item.format.name if item.format
json.tags               item.base_tags.collect{|t| t.name} #tag_list_on('PrimaryArea') # TODO - do we jut want the PrimaryArea or make this configrable
json.desc               item.precis
json.mins               item.duration
json.date               item.start_time.strftime('%Y-%m-%d')
json.time               item.start_time.strftime('%H:%M')
json.datetime           item.start_time
if item.published_room_item_assignment
    json.day            item.published_room_item_assignment.day

    if item.published_room_item_assignment.published_room
        loc = [item.published_room_item_assignment.published_room.name]
        loc = loc << item.published_room_item_assignment.published_room.published_venue.name if !@singleVenue
    else
        loc = []
    end
    loc = loc << "" if @singleVenue
    json.loc        loc
end
json.people     item.published_programme_item_assignments.each do |assignment|
    if assignment.person
        json.id             assignment.person_id
        json.name           (assignment.person_name ? assignment.person_name : assignment.person.getFullPublicationName)
        json.role           assignment.role.name if assignment.role
        json.sort_order     assignment.sort_order
    end
end
json.card_size          item.mobile_card_size

item.external_images.each do |im|
    im.scale = @scale
    if (im.use == :largecard)
        json.large_card         im.picture.large_card.url.partition(@partition_val)[2]
    elsif (im.use == :mediumcard)
        if im.picture.medium_card.url
            json.medium_card        im.picture.medium_card.url.partition(@partition_val)[2]
        end
    end
end

json.parent item.parent_id
if item.children
    json.children item.children.each do |sub_item|
            json.partial! 'item', item: sub_item
    end
end

