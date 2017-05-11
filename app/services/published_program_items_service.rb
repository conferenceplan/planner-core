#
#
#
module PublishedProgramItemsService
  
  #
  #
  #
  def self.determineChangeDate(pubIndex)
    case PublicationDate.count
    when 0
      since_date = Time.now - 1.year 
    when 1
      since_date = ((PublicationDate.order('id asc').first).timestamp - 1.year) 
    else
      selected = PublicationDate.order('id desc').where(['id < ?', pubIndex]).first
      since_date = selected ? selected.timestamp : (pubIndex == 1) ? ((PublicationDate.order('id asc').first).timestamp - 1.year) : PublicationDate.order('id desc').limit(2)[1].timestamp
    end
    
    since_date
  end
  
  #
  #
  #
  def self.findProgramItemsForPerson(person)
    PublishedProgrammeItemAssignment.uncached do
      PublishedProgrammeItemAssignment.
            where(
              ['(programme_item_assignments.person_id = ?) AND (programme_item_assignments.role_id in (?))', 
                person.id, 
                [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id,PersonItemRole['Invisible'].id]]            
            ).
            includes(
              {:published_programme_item => 
                [{:published_programme_item_assignments => 
                  {:person => [:pseudonym, :email_addresses]}}, {:published_room => :published_venue}, :published_time_slot]
                  }
            ).
            references(
              {:published_programme_item => 
                [{:published_programme_item_assignments => 
                  {:person => [:pseudonym, :email_addresses]}}, {:published_room => :published_venue}, :published_time_slot]
                  }
            ).
            order("published_time_slots.start asc")
    end
  end
  
  #
  #
  #
  def self.getPublishedRooms(day = nil, name = nil, lastname = nil)    
    
    PublishedRoom.uncached do
      PublishedRoom.
            references([:published_venue, {:published_room_item_assignments => [:published_time_slot, {:published_programme_item => {:people => :pseudonym}}]}]).
            where(getConditions(day, name, lastname)).
            includes([:published_venue, {:published_room_item_assignments => [:published_time_slot, {:published_programme_item => {:people => :pseudonym}}]}]).
            references([:published_venue, {:published_room_item_assignments => [:published_time_slot, {:published_programme_item => {:people => :pseudonym}}]}]).
            distinct("published_rooms.name").
            order('published_venues.sort_order, published_rooms.sort_order')
    end
    
  end

  def self.countPublishedProgramItems
    PublishedProgrammeItem.count
  end

  
  #
  #
  #
  def self.getPublishedProgramItems(day = nil)

    PublishedProgrammeItem.where("published_programme_items.parent_id is null").
                          references( [
                              :published_time_slot,
                              {
                                :children => [
                                  :external_images, 
                                  :linked
                                ]
                              },
                              :original,
                              :linked,
                              :external_images,
                              {:published_programme_item_assignments => {:person => [:pseudonym]}},
                              {:published_room_item_assignment => [:published_time_slot, {:published_room => [:published_venue]}]} 
                            ] ).
                          includes( [
                              :published_time_slot,
                              {
                                :children => [
#                                    :published_programme_item_assignments,
#                                  {:published_programme_item_assignments => {:person => [:pseudonym]}},
                                  :external_images, 
                                  :linked
                                ]
                              },
                              :original,
                              :linked,
                              :external_images,
                              {:published_programme_item_assignments => {:person => [:pseudonym]}},
                              {:published_room_item_assignment => [:published_time_slot, {:published_room => [:published_venue]}]} 
                            ] ).where(getItemConditions(day, nil)).
                            order('published_time_slots.start ASC, published_venues.sort_order, published_rooms.sort_order')
  end
  
  def self.getPublishedProgramItemsThatHavePeople(itemIds = nil, formatList = nil)
    cndStr = "published_programme_items.parent_id is null"
    cndStr += " AND published_programme_items.id in(?)" if itemIds
    cndStr += " AND published_programme_items.format_id in(?)" if formatList
    conditions = [cndStr]
    conditions << itemIds if itemIds
    conditions << formatList if formatList

    PublishedProgrammeItem.where(conditions).
                            includes([
                              {
                                :children => [
                                   :published_programme_item_assignments,
                                ]
                              },
                              :publication, :published_time_slot, :published_room_item_assignment, :format,
                              {:published_programme_item_assignments => {:person => [:pseudonym, :email_addresses]}},
                              {:published_room => [:published_venue]}                                
                            ]).
                            references([
                              {
                                :children => [
                                   :published_programme_item_assignments,
                                ]
                              },
                              :publication, :published_time_slot, :published_room_item_assignment, :format,
                              {:published_programme_item_assignments => {:person => [:pseudonym, :email_addresses]}},
                              {:published_room => [:published_venue]}                                
                            ]).
                            order('published_time_slots.start, published_venues.sort_order, published_rooms.sort_order') # want day, room, time    
  end
  
  #
  #
  #
  def self.getTaggedPublishedProgramItems(tag, day = nil, term = nil)

    PublishedProgrammeItem.uncached do
      PublishedProgrammeItem.tagged_with(tag, :op => true).
              references([:publication, :published_time_slot, :published_room_item_assignment, 
                  {:people => [:pseudonym, :edited_bio]}, {:published_room => [:published_venue]} 
                  ]).
              where(getItemConditions(day, term)).
              order('published_time_slots.start, published_venues.sort_order, published_rooms.sort_order')
    end

  end
  
  #
  #
  #
  def self.countParticipants(only_public: true)
    roles =  [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id]
    cndStr = ' (published_programme_item_assignments.role_id in (?))'
    cndStr += " AND (published_programme_items.visibility_id = #{Visibility['Public'].id})" if only_public

    conditions = [cndStr]
    conditions << roles
    
    Person.where(conditions).
            joins([:publishedProgrammeItemAssignments]).
            includes(:published_programme_items).
            references(:published_programme_items).
            where(self.constraints()).uniq.count
    
  end
  
  #
  #
  #
  def self.findParticipants(peopleIds = nil, only_public: true)
    roles =  [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id] # ,PersonItemRole['Invisible'].id
    cndStr  = '(published_time_slots.start is not NULL || published_time_slots_published_programme_items.start is not null)'
    cndStr += ' AND (published_programme_item_assignments.person_id in (?))' if peopleIds
    cndStr += ' AND (published_programme_item_assignments.role_id in (?))'
    cndStr += " AND (published_programme_items.visibility_id = #{Visibility['Public'].id})" if only_public

    conditions = [cndStr]
    conditions << peopleIds if peopleIds
    conditions << roles
    
    
    Person.where(conditions).
            includes({
              :pseudonym => {}, 
              :publishedProgrammeItemAssignments => 
                  {
                    :published_programme_item => [
                        :published_time_slot, :published_room, :format,
                        { :parent => [:published_time_slot] },
                      ]
                  }
            }).
            references({
              :pseudonym => {}, 
              :publishedProgrammeItemAssignments => 
                  {
                    :published_programme_item => [
                        :published_time_slot, :published_room, :format,
                        { :parent => [:published_time_slot] },
                      ]
                  }
            }).
            where(self.constraints()).
            order("people.last_name, published_time_slots.start asc")
    
  end
  
  #
  #
  #
  def self.getUpdates(pubDate)

    PublishedProgrammeItemAssignment.uncached do
      deletedItemIds  = getDeletedPublishedProgrammeItems pubDate
      newItemIds      = getNewPublishedProgrammeItems(pubDate).delete_if{ |i| deletedItemIds.include? i } # remove any new that were also deleted in the same period
      updatedItemIds  = getUpdatedPublishedProgrammeItems(pubDate, newItemIds, deletedItemIds)
      
      peopleUpdates   = getUpdatedPeople pubDate
      
      {
        :new_items      => newItemIds,
        :deleted_items  => deletedItemIds,
        :updated_items  => updatedItemIds,
        :updatedPeople  => peopleUpdates[:updatedPeople], # these are people updated or new (i.e. just added to a program item for the first time)
        :removedPeople  => peopleUpdates[:removedPeople]
      }
    end

  end

  #
  # Get a lits of the changes to the published items to be used for the pink sheet(s)
  #
  def self.getPublishedProgrammeItemsChanges(pubDate, new_items = [], deleted_items = [])
    
    translation = {
      'create' => 'add',
      'destroy' => 'remove'
    }
    res = {}

    audits = Audited::Adapters::ActiveRecord::Audit.
                    where(["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItem') AND (audits.action = 'destroy')", pubDate]).
                    order("audits.created_at asc")
      
    audits.each do |a|
      if a.audited_changes['title'] || a.audited_changes['precis']
          item = nil
          item = PublishedProgrammeItem.includes(:published_room_item_assignment).find(a.auditable_id) if PublishedProgrammeItem.exists? a.auditable_id
          res[a.auditable_id] = { :item => item, :deleted => { :title => a.audited_changes['title'], :desc => a.audited_changes['precis'], :created_at => a.created_at} }
      end
    end
    
    audits = Audited::Adapters::ActiveRecord::Audit.
                    where(["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItem') AND (audits.action = 'update')", pubDate]).
                    order("audits.created_at asc")
    
    audits.each do |a|
      if a.audited_changes['title'] || a.audited_changes['precis']
        if PublishedProgrammeItem.exists? a.auditable_id
          item = PublishedProgrammeItem.includes(:published_room_item_assignment).find(a.auditable_id)
          # if multiple changes we want the most recent one to win
          if item && ((!res[a.auditable_id]) || (res[a.auditable_id] && (a.created_at > res[a.auditable_id][:changed][:created_at])))
            res[a.auditable_id] = { :item => item, :changed => { :title => a.audited_changes['title'], :desc => a.audited_changes['precis'], :created_at => a.created_at} }
          end
        end
      end
    end
    
    # assigned to a room and time
    audits = Audited::Adapters::ActiveRecord::Audit.
                    where(["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedRoomItemAssignment') AND ((audits.action = 'create') OR (audits.action = 'update'))", pubDate]).
                    order("audits.created_at asc")
    
    audits.each do |a|
      if PublishedRoomItemAssignment.exists? a.auditable_id
        assignment = PublishedRoomItemAssignment.includes(:published_programme_item).find(a.auditable_id)
        item = assignment.published_programme_item
        if item
          # The changes could be an array to need to know ...
          rm_id = a.audited_changes['published_room_id'].kind_of?(Array) ? a.audited_changes['published_room_id'][1] : a.audited_changes['published_room_id']
          ts_id = a.audited_changes['published_time_slot_id'].kind_of?(Array) ? (has_time_changed(a.audited_changes['published_time_slot_id'][1],a.audited_changes['published_time_slot_id'][0]) ? a.audited_changes['published_time_slot_id'][1] : nil) : a.audited_changes['published_time_slot_id']

          if (PublishedTimeSlot.exists? ts_id) || (PublishedRoom.exists? rm_id)
            time_slot = ts_id && (PublishedTimeSlot.exists? ts_id) ? PublishedTimeSlot.find(ts_id) : nil
            room = rm_id && (PublishedRoom.exists? rm_id) ? PublishedRoom.find(rm_id) : nil
            
            res[item.id] = { :item => item }  if !res[item.id]
            res[item.id][:time] = {:time => time_slot, :created_at => a.created_at} if time_slot && (res[item.id][:time] ? (a.created_at > res[item.id][:time][:created_at]) : true)
            res[item.id][:room] = {:room => room, :created_at => a.created_at} if room && (res[item.id][:room] ? (a.created_at > res[item.id][:room][:created_at]) : true)
          end
        end
      end
    end

    # People added/created/removed
    audits = Audited::Adapters::ActiveRecord::Audit.
                    where(["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItemAssignment')", pubDate]).
                    order("audits.created_at asc")

    audits.each do |a|
      if PublishedProgrammeItem.exists? a.audited_changes['published_programme_item_id']
        item = PublishedProgrammeItem.find a.audited_changes['published_programme_item_id']

        if item
          res[item.id] = { :item => item }  if !res[item.id]
          res[item.id][:people] = {} if !res[item.id][:people]
          res[item.id][:people][a.audited_changes['person_id']] = 
          {:person_name => a.audited_changes['person_name'], 
            :action => translation[a.action],
            :role => Enum.find(a.audited_changes['role_id']).name,
            :created_at => a.created_at} if (
            (res[item.id][:people][a.audited_changes['person_id']] && (res[item.id][:people][a.audited_changes['person_id']][:action] == a.action)) ? (a.created_at > res[item.id][:people][a.audited_changes['person_id']][:created_at]) : true)
        end
      end
    end
    
    res
  end

  def self.has_time_changed(id1, id2)
    changes = Audited::Adapters::ActiveRecord::Audit.
                    select("DISTINCT audited_changes").
                    where(["auditable_type like 'PublishedTimeSlot' and auditable_id in (?)", [id1,id2]])
    
    changes.size > 1
  end
    
  #
  # Get a summary of the changes since the pubDate and what those change were
  #
  def self.getItemChangeHistory(id, pubDate)

    audits = Audited::Adapters::ActiveRecord::Audit.
                      where(["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItem') AND (audits.action = 'update') AND (audits.auditable_id = ?)", pubDate, id]).
                      order("audits.created_at asc")
    
    # We can get the ids of the changes - then we need to decide on what the change was
    
    # item updated - change of title or description
            
    # Time and/or place change
    # removed and assigned to room
    # time changed
            
    # Participant change
    # person added
    # person removed
    # person role changed
    
  end
  
  # new people - PublishedProgrammeItemAssignment
  # updated people - PublishedProgrammeItemAssignment
  # deleted people - PublishedProgrammeItemAssignment
  #
  def self.getUpdatedPeople(pubDate)
    # People added or updated
    audits = Audited::Adapters::ActiveRecord::Audit.
                    where(["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItemAssignment') AND (audits.action = 'create')", pubDate]).
                    order("audits.created_at asc")
    updateOrAdded = audits.collect {|a| a.audited_changes['person_id'] }
      
    # People role changed, could be from reserved to participant or vice-versa
    audits = Audited::Adapters::ActiveRecord::Audit.
                    where(["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItemAssignment') AND (audits.action = 'update')", pubDate]).
                    order("audits.created_at asc")
    updateOrAdded = updateOrAdded.concat audits.collect {|a| (PublishedProgrammeItemAssignment.exists? a.auditable_id) ? PublishedProgrammeItemAssignment.find(a.auditable_id).person_id : nil}.compact

    # and if they had an image updated
    # Get the image updates
    ext_images = BioImage.where(["(updated_at >= ?)", pubDate]).order("updated_at asc")
    updateOrAdded = updateOrAdded.concat ext_images.collect {|a| a.person_id }.compact
    
    # Find people that are assigned to items and have had their details updated...
    audits = Audited::Adapters::ActiveRecord::Audit.
                    where(["(audits.created_at >= ?) AND (audits.auditable_type like 'Person') AND (audits.action != 'destroy')", pubDate]).
                    order("audits.created_at asc")
    updateOrAdded = updateOrAdded.concat audits.collect {|a| (Person.exists? a.auditable_id) ? a.auditable_id : nil }.compact
    
    # Find people with edited bios that have been updated that also are assigned to programme items
    audits = Audited::Adapters::ActiveRecord::Audit.
                    where(["(audits.created_at >= ?) AND (audits.auditable_type like 'EditedBio') AND (audits.action != 'destroy')", pubDate]).
                    order("audits.created_at asc")
    updateOrAdded = updateOrAdded.concat audits.collect {|a| (EditedBio.exists? a.auditable_id) ? EditedBio.find(a.auditable_id).person_id : nil }.compact
    
    # Find people with pseudonyms that have been updated
    audits = Audited::Adapters::ActiveRecord::Audit.
                    where(["(audits.created_at >= ?) AND (audits.auditable_type like 'Pseudonym') AND (audits.action != 'destroy')", pubDate]).
                    order("audits.created_at asc")
    updateOrAdded = updateOrAdded.concat audits.collect {|a| (Pseudonym.exists? a.auditable_id) ? Pseudonym.find(a.auditable_id).person_id : nil }.compact

    # get the document updates - TODO - fix remove document ref
    audits = Audited::Adapters::ActiveRecord::Audit.
                    where(["(audits.created_at >= ?) AND (audits.auditable_type like 'PlannerDocs::Document') AND ((audits.action = 'update') OR (audits.action = 'create'))", pubDate]).
                    order("audits.created_at asc")
    updateOrAdded = updateOrAdded.concat audits.collect {|a| (PlannerDocs::Document.exists? a.auditable_id) ? PlannerDocs::Document.find(a.auditable_id).people.collect{|i| i.id} : nil }.compact.flatten

    # and also deal with the document deletes
    audits = Audited::Adapters::ActiveRecord::Audit.
                    where(["(audits.created_at >= ?) AND (audits.auditable_type like 'Link') AND (audits.action = 'destroy')", pubDate]).
                    order("audits.created_at asc")
    updateOrAdded = updateOrAdded.concat audits.collect {|a| (a.audited_changes['linkedto_type'] == 'Person') ? a.audited_changes['linkedto_id'] : nil}.compact

    updateOrAdded = updateOrAdded.collect {|i| (Person.exists? i) ? ((Person.find(i).publishedProgrammeItemAssignments.size > 0) ? i : nil) : nil }.compact.uniq

    # People removed - we only want to know who no longer has any items assigned to them, otherwise these are updated people (i.e. removed from an item)
    audits = Audited::Adapters::ActiveRecord::Audit.
                    where(["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItemAssignment') AND (audits.action = 'destroy')", pubDate]).
                    order("audits.created_at asc")
    removed = audits.collect {|a| (Person.exists? a.audited_changes['person_id']) ? (Person.find(a.audited_changes['person_id']).publishedProgrammeItemAssignments.size == 0) ? a.audited_changes['person_id'] : nil : a.audited_changes['person_id'] }.compact.uniq
    
    { :updatedPeople => updateOrAdded, :removedPeople => removed }
  end
  
  def self.countUpdatedPeople(pubDate)
    count = 0

    # TODO - need to deal with dups ...     
    count = Audited::Adapters::ActiveRecord::Audit.where(
        ["(audits.created_at >= ?) AND (audits.action != 'destroy') AND (audits.auditable_type in (?))", 
          pubDate, 
          ['PublishedProgrammeItemAssignment', 'Person', 'EditedBio', 'Pseudonym', 'PlannerDocs::Document']
        ]
    ).count 
      
    count +=  BioImage.where(["(updated_at >= ?)", pubDate]).count 

    count      
  end

private
  
  def self.getNewPublishedProgrammeItems(pubDate)
    audits = Audited::Adapters::ActiveRecord::Audit.
                where(["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItem') AND (audits.action = 'create')", pubDate]).
                order("audits.created_at asc")
      
    audits.collect { |a| a.auditable_id } # do by id?
  end
  
  def self.getDeletedPublishedProgrammeItems(pubDate)
    audits = Audited::Adapters::ActiveRecord::Audit.
                where(["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItem') AND (audits.action = 'destroy')", pubDate]).
                order("audits.created_at asc")
    
    audits.collect { |a| a.auditable_id } # do by id?
  end
  
  #
  # new items - new PublishedProgrammeItem
  # updated items - PublishedRoomItemAssignment, and PublishedProgrammeItemAssignment, and PublishedProgrammeItem (also PublishedTimeSlot)
  # deleted items - delete PublishedProgrammeItem
  #
  def self.getUpdatedPublishedProgrammeItems(pubDate, new_items = [], deleted_items = [])
    
    audits = Audited::Adapters::ActiveRecord::Audit.
                  where(["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItem') AND (audits.action = 'update')", pubDate]).
                  order("audits.created_at asc")
    updated = audits.collect { |a| a.auditable_id }
    
    # removed from room and time (check to see if the item is still published)
    audits = Audited::Adapters::ActiveRecord::Audit.
                  where(["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedRoomItemAssignment') AND (audits.action = 'destroy')", pubDate]).
                  order("audits.created_at asc")
    updated = updated.concat audits.collect {|a| a.audited_changes['published_programme_item_id'] } # also get a list of the roomitemassignment ids and use that to filter the subsequent collections
    
    # assigned to a room and time
    audits = Audited::Adapters::ActiveRecord::Audit.
                  where(["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedRoomItemAssignment') AND (audits.action = 'create')", pubDate]).
                  order("audits.created_at asc")
    updated = updated.concat audits.collect {|a| a.audited_changes['published_programme_item_id'] }

    # room and/or time changed
    audits = Audited::Adapters::ActiveRecord::Audit.
                  where(["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedRoomItemAssignment') AND (audits.action = 'update')", pubDate]).
                  order("audits.created_at asc")
      # go through the assigment to get to the actual item ... and make sure they were not subsequentally deleted
    updated = updated.concat audits.collect {|a| (PublishedRoomItemAssignment.exists? a.auditable_id) ? PublishedRoomItemAssignment.find(a.auditable_id).published_programme_item_id : nil }.compact
      
    # People added
    audits = Audited::Adapters::ActiveRecord::Audit.
                  where(["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItemAssignment') AND (audits.action = 'create')", pubDate]).
                  order("audits.created_at asc")
    updated = updated.concat audits.collect {|a| a.audited_changes['published_programme_item_id'] }
      
    # People removed
    audits = Audited::Adapters::ActiveRecord::Audit.
                  where(["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItemAssignment') AND (audits.action = 'destroy')", pubDate]).
                  order("audits.created_at asc")
    updated = updated.concat audits.collect {|a| a.audited_changes['published_programme_item_id'] }
    
    # People role changed
    audits = Audited::Adapters::ActiveRecord::Audit.
                  where(["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedProgrammeItemAssignment') AND (audits.action = 'update')", pubDate]).
                  order("audits.created_at asc")
    updated = updated.concat audits.collect {|a| (PublishedProgrammeItemAssignment.exists? a.auditable_id) ? PublishedProgrammeItemAssignment.find(a.auditable_id).published_programme_item_id : nil }.compact
    
    # Now find the items associated with rooms (and venues) that have changed
    audits = Audited::Adapters::ActiveRecord::Audit.
                  where(["(audits.created_at >= ?) AND (audits.auditable_type like 'PublishedRoom') AND (audits.action = 'update')", pubDate]).
                  order("audits.created_at asc")
    updated = updated.concat audits.collect {|a| (PublishedRoom.exists? a.auditable_id) ? PublishedRoom.find(a.auditable_id).published_programme_items.collect{|i| i.id} : nil }.compact.flatten

    audits = Audited::Adapters::ActiveRecord::Audit.
                  joins('join external_images on external_images.id = audits.auditable_id').
                  where(
                    ["(audits.created_at >= ?) AND (audits.auditable_type like 'ExternalImage') AND (audits.action = 'create')", pubDate]
                  ).
                  order("audits.created_at asc")
    updated = updated.concat audits.collect {|a| (ExternalImage.exists? a.auditable_id) ? (ExternalImage.find(a.auditable_id).imageable_type == "PublishedProgrammeItem" ? ExternalImage.find(a.auditable_id).imageable_id : nil) : nil }.compact
    
    # Get the image updates
    ext_images = ExternalImage.where(["(updated_at >= ?) AND (imageable_type like 'PublishedProgrammeItem')", pubDate]).order("updated_at asc")
    updated = updated.concat ext_images.collect {|a| a.imageable_id }.compact

    # get the document updates
    audits = Audited::Adapters::ActiveRecord::Audit.
                  where(["(audits.created_at >= ?) AND (audits.auditable_type like 'PlannerDocs::Document') AND ((audits.action = 'update') OR (audits.action = 'create'))", pubDate]).
                  order("audits.created_at asc")
    updated = updated.concat audits.collect {|a| (PlannerDocs::Document.exists? a.auditable_id) ? PlannerDocs::Document.find(a.auditable_id).published_programme_items.collect{|i| i.id} : nil }.compact.flatten

    # and also deal with the document deletes
    audits = Audited::Adapters::ActiveRecord::Audit.
                  where(["(audits.created_at >= ?) AND (audits.auditable_type like 'Link') AND (audits.action = 'destroy')", pubDate]).
                  order("audits.created_at asc")
    updated = updated.concat audits.collect {|a| (a.audited_changes['linkedto_type'] == 'PublishedProgrammeItem') ? a.audited_changes['linkedto_id'] : nil}.compact
      
    updated.uniq.delete_if{ |i| new_items.include? i }.delete_if{ |i| deleted_items.include? i }
  end

private

  def self.getItemConditions(day, term)
    if (day)
      cfg = SiteConfig.first
      start_of_day = cfg.start_date + day.to_i.days
      end_of_day = start_of_day + 1.days
    end
    
    # TODO - ensure we also use tags ....
    
    # Only return items that are not children
    conditionStr = "(published_programme_items.parent_id is null)" # if (day || term)
    conditionStr += ' AND (published_time_slots.start >= ? AND published_time_slots.start < ?) ' if day
    if term
      conditionStr += ' AND ' if day
      conditionStr += '('
      conditionStr += 'people.last_name like ? OR pseudonyms.last_name like ? OR people.first_name like ? OR pseudonyms.first_name like ? '
      conditionStr += ' OR published_programme_items.title like ? '
      conditionStr += ' OR published_programme_items.precis like ? '
      conditionStr += ')'
    end

    conditions = [conditionStr] #if (day || term)
    conditions += [start_of_day, end_of_day] if day 
    conditions += ['%'+term+'%', '%'+term+'%', '%'+term+'%', '%'+term+'%', '%'+term+'%', '%'+term+'%'] if term
    conditions    
  end

  def self.getConditions(day = nil, name = nil, lastname = nil)
    # get the start date
    # find the day start_date + day.days@
    if (day)
      cfg = SiteConfig.first
      start_of_day = cfg.start_date + day.to_i.days
      end_of_day = start_of_day + 1.days
    end
    
    conditionStr = "" if (day || name || lastname)
    # conditionStr += '(published_room_item_assignments.day = ?) ' if day
    conditionStr += '(published_time_slots.start >= ? AND published_time_slots.start < ?) ' if day
    conditionStr += ' AND ' if day && (name || lastname)
    conditionStr += '(people.last_name like ? OR pseudonyms.last_name like ? OR people.first_name like ? OR pseudonyms.first_name like ? )' if name && !lastname
    conditionStr += '((people.last_name like ? OR pseudonyms.last_name like ?) AND (people.first_name like ? OR pseudonyms.first_name like ?))' if name && lastname
    conditionStr += '(people.last_name like ? OR pseudonyms.last_name like ?)' if lastname && !name
    conditions = [conditionStr] if (day || name || lastname)
    # conditions << day if day 
    conditions += [start_of_day, end_of_day] if day 
    lastname = name if !lastname
    conditions += ['%'+lastname+'%', '%'+lastname+'%', '%'+name+'%', '%'+name+'%'] if name
    conditions += ['%'+lastname+'%', '%'+lastname+'%'] if lastname && !name
    conditions
  end

  def self.constraints(*args)
    nil
  end
  
end
