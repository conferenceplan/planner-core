
json.removed    @changes[:deleted_items]
json.new        @changes[:new_items].each do |itemid| 
    json.partial! 'item', item: PublishedProgrammeItem.find(itemid)
end
json.updates    @changes[:updated_items].each do |itemid| 
    json.partial! 'item', item: PublishedProgrammeItem.find(itemid)
end
json.peopleAddedUpdated    @changes[:updatedPeople].each do |personid|
    json.partial! 'person_detail', person: Person.find(personid)
end
json.peopleRemoved  @changes[:removedPeople]
