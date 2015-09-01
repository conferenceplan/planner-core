
json.id                 item.id    
json.lock_version       item.lock_version    
json.updated_at         item.updated_at.utc
json.created_at         item.created_at.utc
json.title              item.title    
json.format             item.format.name if item.format
json.tags               item.base_tags.collect{|t| t.name} #tag_list_on('PrimaryArea') # TODO - do we jut want the PrimaryArea or make this configrable
json.desc               item.precis
json.mins               item.duration
if item.published_room_item_assignment
    json.day            item.published_room_item_assignment.day
    json.date           item.published_time_slot.start.strftime('%Y-%m-%d')
    json.time           item.published_time_slot.start.strftime('%H:%M')
    json.datetime       item.published_time_slot.start

    loc = [item.published_room_item_assignment.published_room.name]
    loc = loc << item.published_room_item_assignment.published_room.published_venue.name if !@singleVenue
    loc = loc << "" if @singleVenue
    json.loc        loc
end
json.people     item.published_programme_item_assignments.each do |assignment|
    json.id             assignment.person_id
    json.name           (assignment.person_name ? assignment.person_name : assignment.person.getFullPublicationName)
    json.role           assignment.role.name if assignment.role
end
json.card_size          item.mobile_card_size

#item.external_images.each do |im|
#    im.scale = @scale
#    if (im.use == :largecard)
#        json.large_card         im.picture.large_card.url.partition(@partition_val)[2]
#    elsif (im.use == :mediumcard)
#        if im.picture.medium_card.url
#            json.medium_card        im.picture.medium_card.url.partition(@partition_val)[2]
#        else
#            json.medium_card        "PROBLEM"
#        end
#    end
#end
    
imLarge = ImageService.getExternalImage(item,:largecard)[0] #item.external_images.use(:largecard)[0]
imLarge.scale = @scale if imLarge
json.large_card         imLarge.picture.large_card.url.partition(@partition_val)[2] if imLarge
imMedium = ImageService.getExternalImage(item,:mediumcard)[0] #item.external_images.use(:mediumcard)[0]
imMedium.scale = @scale if imMedium
json.medium_card        imMedium.picture.medium_card.url.partition(@partition_val)[2] if imMedium

json.parent item.parent_id
if item.children
    json.children item.children.each do |sub_item|
            json.partial! 'item', item: sub_item
    end
end

