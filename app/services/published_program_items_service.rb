#
#
#
module PublishedProgramItemsService
  
  #
  #
  #
  def self.findProgramItemsForPerson(person)
    PublishedProgrammeItemAssignment.all(
        :conditions => ['(programme_item_assignments.person_id = ?) AND (programme_item_assignments.role_id in (?))', 
            person.id, 
            [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id,PersonItemRole['Invisible'].id]],
            :include => {:published_programme_item => [{:published_programme_item_assignments => {:person => [:pseudonym, :email_addresses]}}, {:published_room => :published_venue}, :published_time_slot]},
            :order => "published_time_slots.start asc"
    )
  end
  
  #
  #
  #
  def self.getPublishedRooms(day = nil, name = nil, lastname = nil)    
    
    PublishedRoom.all :select => 'distinct published_rooms.name',
                      :order => 'published_venues.name DESC, published_rooms.name ASC', 
                      :include => [:published_venue, {:published_room_item_assignments => {:published_programme_item => {:people => :pseudonym}}}],
                      :conditions => getConditions(day, name, lastname)

  end
  
  #
  #
  #
  def self.getPublishedProgramItems(day = nil, name = nil, lastname = nil)

    PublishedProgrammeItem.all :order => 'published_time_slots.start ASC, published_venues.name DESC, published_rooms.name ASC',
                              :include => [:publication, :published_time_slot, {:published_room_item_assignment => {:published_room => [:published_venue]}}, {:people => [:pseudonym, :edited_bio]} ],
                               :conditions => getConditions(day, name, lastname)

  end
  
  def self.getPublishedProgramItemsThatHavePeople

    PublishedProgrammeItem.all :include => [:publication, :published_time_slot, :published_room_item_assignment, {:people => [:pseudonym, :edited_bio]}, {:published_room => [:published_venue]} ],
                               :order => 'published_programme_items.title ASC',
                               :conditions => "published_programme_item_assignments.id is not null"

  end
  
  #
  #
  #
  def self.getTaggedPublishedProgramItems(tag, day = nil, name = nil, lastname = nil)

    PublishedProgrammeItem.tagged_with(tag, :on => 'PrimaryArea', :op => true).all(
                                        :include => [:publication, :published_time_slot, :published_room_item_assignment, {:people => [:pseudonym, :edited_bio]}, {:published_room => [:published_venue]} ],
                                        :order => 'published_time_slots.start ASC, published_venues.name DESC, published_rooms.name ASC',
                                        :conditions => getConditions(day, name, lastname) )

  end
  
  #
  #
  #
  def self.findParticipants(peopleIds = nil)
    roles =  [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id] # ,PersonItemRole['Invisible'].id
    cndStr  = '(published_time_slots.start is not NULL)'
    cndStr += ' AND (published_programme_item_assignments.person_id in (?))' if peopleIds
    cndStr += ' AND (published_programme_item_assignments.role_id in (?))'

    conditions = [cndStr]
    conditions << peopleIds if peopleIds
    conditions << roles
    
    Person.all :conditions => conditions, 
              :include => {:pseudonym => {}, :publishedProgrammeItemAssignments => {:published_programme_item => [:published_time_slot, :published_room, :format]}},
              :order => "people.last_name, published_time_slots.start asc"

  end
  
  #
  #
  #
  def self.getUpdates(pubDate)
    
    deletedItemIds  = getDeletedPublishedProgrammeItems pubDate
    newItemIds      = getNewPublishedProgrammeItems(pubDate).delete_if{ |i| deletedItemIds.include? i } # remove any new that were also deleted in the same period
    updatedItemIds  = getUpdatedPublishedProgrammeItems(pubDate, newItemIds, deletedItemIds)
    
    peopleUpdates   = getUpdatedPeople pubDate
    
    # TODO - we also need to get updates to people such as BIOs and URLs
    # TODO - we also need to get updates to items when a room or venue is renamed...
    
    {
      :new_items      => newItemIds,
      :deleted_items  => deletedItemIds,
      :updated_items  => updatedItemIds,
      :updatedPeople  => peopleUpdates[:updatedPeople], # these are people updated or new (i.e. just added to a program item for the first time)
      :removedPeople  => peopleUpdates[:removedPeople]
    }
  end
  
private
  
  def self.getNewPublishedProgrammeItems(pubDate)
    
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItem') AND (audits.action = 'create')", pubDate.timestamp]
      
    audits.collect { |a| a.auditable_id } # do by id?
    
  end
  
  def self.getDeletedPublishedProgrammeItems(pubDate)
    
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItem') AND (audits.action = 'destroy')", pubDate.timestamp]
      
    # audits.collect { |a| PublishedProgrammeItem.find(a.auditable_id) }
    audits.collect { |a| a.auditable_id } # do by id?
    
  end
  
  #
  # new items - new PublishedProgrammeItem
  # updated items - PublishedRoomItemAssignment, and PublishedProgrammeItemAssignment, and PublishedProgrammeItem (also PublishedTimeSlot)
  # deleted items - delete PublishedProgrammeItem
  #
  def self.getUpdatedPublishedProgrammeItems(pubDate, new_items = [], deleted_items = [])
    
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItem') AND (audits.action = 'update')", pubDate.timestamp]
      
    updated = audits.collect { |a| a.auditable_id }
    
    # removed from room and time (check to see if the item is still published)
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedRoomItemAssignment') AND (audits.action = 'destroy')", pubDate.timestamp]
    updated = updated.concat audits.collect {|a| a.audited_changes['published_programme_item_id'] } # also get a list of the roomitemassignment ids and use that to filter the subsequent collections
    
    # assigned to a room and time
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedRoomItemAssignment') AND (audits.action = 'create')", pubDate.timestamp]
    updated = updated.concat audits.collect {|a| a.audited_changes['published_programme_item_id'] }

    # room and/or time changed
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedRoomItemAssignment') AND (audits.action = 'update')", pubDate.timestamp]
      # go through the assigment to get to the actual item ... and make sure they were not subsequentally deleted
    updated = updated.concat audits.collect {|a| (PublishedRoomItemAssignment.exists? a.auditable_id) ? PublishedRoomItemAssignment.find(a.auditable_id).published_programme_item_id : nil }.compact
      
    # People added
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItemAssignment') AND (audits.action = 'create')", pubDate.timestamp]
    updated = updated.concat audits.collect {|a| a.audited_changes['published_programme_item_id'] }
      
    # People removed
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItemAssignment') AND (audits.action = 'destroy')", pubDate.timestamp]
    updated = updated.concat audits.collect {|a| a.audited_changes['published_programme_item_id'] }
    
    # People role changed
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItemAssignment') AND (audits.action = 'update')", pubDate.timestamp]
    updated = updated.concat audits.collect {|a| (PublishedProgrammeItemAssignment.exists? a.auditable_id) ? PublishedProgrammeItemAssignment.find(a.auditable_id).published_programme_item_id : nil }.compact
    
    # Now find the items associated with rooms (and venues) that have changed
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedRoom') AND (audits.action = 'update')", pubDate.timestamp]
    updated = updated.concat audits.collect {|a| (PublishedRoom.exists? a.auditable_id) ? PublishedRoom.find(a.auditable_id).published_programme_items.collect{|i| i.id} : nil }.compact.flatten

    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'ExternalImage') AND ((audits.action = 'update') OR (audits.action = 'create'))", pubDate.timestamp],
      :joins => 'join external_images on external_images.id = audits.auditable_id'
    updated = updated.concat audits.collect {|a| (ExternalImage.exists? a.auditable_id) ? (ExternalImage.find(a.auditable_id).imageable_type == "PublishedProgrammeItem" ? ExternalImage.find(a.auditable_id).imageable_id : nil) : nil }.compact
      
    updated.uniq.delete_if{ |i| new_items.include? i }.delete_if{ |i| deleted_items.include? i }
  end
  
  # new people - PublishedProgrammeItemAssignment
  # updated people - PublishedProgrammeItemAssignment
  # deleted people - PublishedProgrammeItemAssignment
  #
  def self.getUpdatedPeople(pubDate)
    # People added or updated
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItemAssignment') AND (audits.action = 'create')", pubDate.timestamp]
    updateOrAdded = audits.collect {|a| a.audited_changes['person_id'] }
      
    # People role changed, could be from reserved to participant or vice-versa
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItemAssignment') AND (audits.action = 'update')", pubDate.timestamp]
    updateOrAdded = updateOrAdded.concat audits.collect {|a| (PublishedProgrammeItemAssignment.exists? a.auditable_id) ? PublishedProgrammeItemAssignment.find(a.auditable_id).person_id : nil}.compact

    updateOrAdded = updateOrAdded.collect {|i| (Person.find(i).publishedProgrammeItemAssignments.size > 0) ? i : nil }.compact

    # People removed - we only want to know who no longer has any items assigned to them, otherwise these are updated people (i.e. removed from an item)
    audits = Audited::Adapters::ActiveRecord::Audit.all :order => "audits.created_at asc",
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItemAssignment') AND (audits.action = 'destroy')", pubDate.timestamp]
    removed = audits.collect {|a| (Person.find(a.audited_changes['person_id']).publishedProgrammeItemAssignments.size == 0) ? a.audited_changes['person_id'] : nil }.compact
    
    { :updatedPeople => updateOrAdded, :removedPeople => removed }
  end

private

  def self.getConditions(day = nil, name = nil, lastname = nil)    
    conditionStr = "" if (day || name || lastname)
    conditionStr += '(published_room_item_assignments.day = ?) ' if day
    conditionStr += ' AND ' if day && (name || lastname)
    conditionStr += '(people.last_name like ? OR pseudonyms.last_name like ? OR people.first_name like ? OR pseudonyms.first_name like ? )' if name && !lastname
    conditionStr += '((people.last_name like ? OR pseudonyms.last_name like ?) AND (people.first_name like ? OR pseudonyms.first_name like ?))' if name && lastname
    conditionStr += '(people.last_name like ? OR pseudonyms.last_name like ?)' if lastname && !name
    conditions = [conditionStr] if (day || name || lastname)
    conditions << day if day 
    lastname = name if !lastname
    conditions += ['%'+lastname+'%', '%'+lastname+'%', '%'+name+'%', '%'+name+'%'] if name
    conditions += ['%'+lastname+'%', '%'+lastname+'%'] if lastname && !name
    conditions
  end
  
end
