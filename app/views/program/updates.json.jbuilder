
if @changes
    json.removed    @changes[:deleted_items]
    json.new        @changes[:new_items].each do |itemid| 
        json.partial! 'item', item: PublishedProgrammeItem.find(itemid)
        @extra_item_json.each do |extra|
            json.partial! extra, item: PublishedProgrammeItem.find(itemid)
        end
    end
    json.updates    @changes[:updated_items].each do |itemid| 
        json.partial! 'item', item: PublishedProgrammeItem.find(itemid)
        @extra_item_json.each do |extra|
            json.partial! extra, item: PublishedProgrammeItem.find(itemid)
        end
    end
    json.peopleAddedUpdated    @changes[:updatedPeople].each do |personid|
        json.partial! 'person_detail', person: Person.find(personid)
    end
    json.peopleRemoved  @changes[:removedPeople]
else
    json.removed    []
    json.new        []
    json.updates    []
    json.peopleAddedUpdated []
    json.peopleRemoved  []
end
