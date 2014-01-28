
json.id         item.id    
json.title      item.title    
json.format     item.format.name
json.tags       item.tag_list_on('PrimaryArea') # TODO - do we jut want the PrimaryArea or make this configrable
json.desc       item.precis
json.mins       item.duration
json.day        item.published_room_item_assignment.day
json.date       item.published_time_slot.start.strftime('%Y-%m-%d')
json.time       item.published_time_slot.start.strftime('%H:%M')
json.datetime   item.published_time_slot.start
json.loc        [item.published_room_item_assignment.published_room.name, item.published_room_item_assignment.published_room.published_venue.name]
json.people     item.published_programme_item_assignments.each do |assignment| 
    json.partial! 'person', person: assignment.person, role: assignment.role.name if [PersonItemRole['Moderator'], PersonItemRole['Participant']].include? assignment.role
end
json.card_size  item.mobile_card_size
