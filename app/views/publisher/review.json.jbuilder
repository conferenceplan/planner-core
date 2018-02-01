
json.new_items      @candidateNewItems
json.modified_items @candidateModifiedItems
json.removed_items  @candidateRemovedItems

json.modifed_rooms @candidateRooms do |room|
  json.id room.id
  json.name room.name
end

json.modifed_venues @candidateVenues do |venue|
  json.id venue.id
  json.name venue.name
end

if @peopleChanged
    json.people_added_updated    @peopleChanged[:updatedPeople].each do |personid|
        json.person_name Person.find(personid).getFullPublicationName
    end
    json.people_removed    @peopleChanged[:removedPeople].each do |personid|
        json.person_name Person.find(personid).getFullPublicationName if Person.exists? personid
    end
end

# add extra
@extra_pub_review_json.each do |extra|
    json.partial! extra
end
