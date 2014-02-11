
json.new_items      @candidateNewItems
json.modified_items @candidateModifiedItems
json.removed_items  @candidateRemovedItems

if @peopleChanged
    json.people_added_updated    @peopleChanged[:updatedPeople].each do |personid|
        json.person_name Person.find(personid).getFullPublicationName
    end
    json.people_removed    @peopleChanged[:removedPeople].each do |personid|
        json.person_name Person.find(personid).getFullPublicationName
    end
end
