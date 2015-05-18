require 'job_utils'

class PublishJob

  include JobUtils
  
  def initialize(ref_numbers)
    @ref_numbers = ref_numbers
  end
  
  def before(job)
    Planner::Linkable.configure do |config|
      config.addLinkable [Person, ProgrammeItem, PublishedProgrammeItem, Venue, Room]
    end
    ActiveRecord::Base.send(:include, Planner::Linkable)
    Planner::Linkable.setup
  end
  
  def perform
    cfg = getSiteConfig
    zone = cfg ? cfg.time_zone : Time.zone
    Time.use_zone(zone) do
      PublishedProgrammeItem.transaction do
        load_cloudinary_config
        
        ProgramItemsService.assign_reference_numbers if @ref_numbers #
        
        newItems = 0
        modifiedItems = 0
        renmovedItems = 0
        p = PublicationDate.new
        newItems = copyProgrammeItems(getNewProgramItems()) # copy all unpublished programme items
        modifiedItems = copyProgrammeItems(getModifiedProgramItems()) # copy all programme items that have changes made (room assignment, added person, details etc)
        removedItems = unPublish(getRemovedProgramItems()) # remove all items that should no longer be published
        removedItems += unPublish(getUnpublishedItems()) # remove all items that should no longer be published
        
        modifiedItems += publishRooms(getModifiedRooms())
        
        updateAssignmentNames()
        
        PublishedProgrammeItem.transaction do
          sleep 2 # fudge to make sure that the datetime is definitely later than the other transactions!!
          
          p.timestamp = DateTime.current
          p.newitems = newItems
          p.modifieditems = modifiedItems
          p.removeditems = renmovedItems
          p.save
        end
  
        pstatus = PublicationStatus.first
        pstatus = PublicationStatus.new if pstatus == nil
        pstatus.status = :completed
        pstatus.save!
        
      end
      Rails.cache.clear # make sure that the mem cache is flushed
      clearDalliCache # clear the mem cache ...
      post_process
    end
  end
  
  def post_process
    
  end
  
  def clearDalliCache
    if Rails.cache.respond_to? :dalli
      Rails.cache.dalli.with do |client|
        client.flush
      end    
    end
  end

  #
  #
  #
  def updateAssignmentNames
    assignments = PublishedProgrammeItemAssignment.where('published_programme_item_assignments.updated_at < people.updated_at' ).joins(:person)
    assignments.each do |assignment|
      a = PublishedProgrammeItemAssignment.find assignment.id
      a.person_name = assignment.person.getFullPublicationName
      a.touch
      a.save
    end
  end
  
  # Select from publications and room item assignments items where published_id is not in the room item assignments items
  def getNewProgramItems
    clause = addClause(nil,'print = ?',true) # only get those that are marked for print
    clause = addClause(clause,'programme_items.id not in (select publications.original_id from publications where publications.original_type = ?)', 'ProgrammeItem')
    clause = addClause(clause,'room_item_assignments.id is not null ', nil)
#    clause = addClause(clause,'programme_item_assignments.role_id != ? ', PersonItemRole['Reserved'])
    args = { :conditions => clause, :include => :room_item_assignment } #, :programme_item_assignments] }
    return ProgrammeItem.find :all, args
  end

  #  
  def getModifiedRooms
    rooms = Room.find :all
    rooms.collect {|r| (r.published && (r.updated_at > r.published.updated_at)) ? r : nil}.compact
  end
  
  # Check this for modified items - i.e what happens if the time is changed?
  # in that case the room item assignment is recreated...
  def getModifiedProgramItems
    clause = addClause(nil,'print = ?',true) # only get those that are marked for print
    clause = addClause(clause,'room_item_assignments.id is not null ', nil)
    clause = addClause(clause,'programme_items.id in (select publications.original_id from publications where publications.original_type = ?)', 'ProgrammeItem')
    clause = addClause(clause,'((select timestamp from publication_dates order by timestamp desc limit 1) < external_images.updated_at) OR ((select timestamp from publication_dates order by timestamp desc limit 1) < programme_items.updated_at) OR ((select timestamp from publication_dates order by timestamp desc limit 1) < room_item_assignments.updated_at) OR ((select timestamp from publication_dates order by timestamp desc limit 1) < programme_item_assignments.updated_at)', nil)
    # check the date of the programme item compared with the published
    args = { :conditions => clause, :include => [:room_item_assignment, :programme_item_assignments, :publication, :external_images, :linked] }
    return ProgrammeItem.find :all, args
  end

  def getRemovedProgramItems
    PublishedProgrammeItem.joins("left outer join publications on (publications.published_id = published_programme_items.id AND publications.published_type = 'PublishedProgrammeItem')").
      joins("LEFT OUTER JOIN room_item_assignments on publications.original_id = room_item_assignments.programme_item_id").
      where("room_item_assignments.id is null OR publications.id is null")
  end

  def getUnpublishedItems
    PublishedProgrammeItem.joins("left outer join publications on (publications.published_id = published_programme_items.id AND publications.published_type = 'PublishedProgrammeItem')").
      joins("join programme_items on programme_items.id = publications.original_id and publications.original_type = 'ProgrammeItem'").
      where("programme_items.print = 0 AND publications.published_id is not null")
  end

  private
  
  def addClause(clause, clausestr, field)
    if clause == nil || clause.empty?
      clause = [clausestr, field]
    else
      isEmpty = clause[0].strip().empty?
      clause[0] = " ( " + clause[0]
      clause[0] += ") AND ( " if ! isEmpty
      clause[0] += " " + clausestr
      clause[0] += " ) "  if ! isEmpty
      if field
        clause << field
      end
    end
    
    return clause
  end
  
  def getRemovedParticipants
    # Select from publications and programme item assignments where published_id is not in the programme item assignments
  end
  
  def unPublish(pubItems)
    nbrProcessed = 0
    PublishedProgrammeItem.transaction do
      pubItems.each do |item|
        item.destroy
        nbrProcessed += 1
      end
    end
    return nbrProcessed
  end
  
  def copyProgrammeItems(srcItems)
    nbrProcessed = 0
    PublishedProgrammeItem.transaction do
      srcItems.each do |srcItem|
        # check for existence of already published item and if it is there then use that
        newItem = (srcItem.published == nil) ? PublishedProgrammeItem.new : srcItem.published
        
        # # copy the details from the unpublished item to the new
        newItem = copy(srcItem, newItem)
        newItem.original = srcItem if srcItem.published == nil # this create the Publication record as well to tie the two together
        # and once fixed we need to 'touch' all the items
        copyTags(srcItem, newItem)
        
        newItem.touch #update_attribute(:updated_at,Time.now)
        newItem.save
        
        updateImages(srcItem, newItem)
        updateLinks(srcItem, newItem)

        # link to the people (and their roles)
        updateAssignments(srcItem, newItem)
        
        newRoom = publishRoom(srcItem.room)
        if newItem.published_room_item_assignment
          newItem.published_room = newRoom if newItem.published_room != newRoom # change the room if necessary
          
          # Only need to copy time if the new time slot is more recent than the published
          if newItem.published_time_slot != nil
            if srcItem.time_slot.updated_at > newItem.published_time_slot.updated_at
              newItem.published_time_slot.delete # if we are changing time slot then clean up the old one
              newTimeSlot = copy(srcItem.time_slot, PublishedTimeSlot.new) 
              newTimeSlot.save
              newItem.published_time_slot = newTimeSlot
              newItem.save
            end
          else
              newTimeSlot = copy(srcItem.time_slot, PublishedTimeSlot.new) 
              newTimeSlot.save
              newItem.published_time_slot = newTimeSlot
              newItem.save
          end
          newItem.published_room_item_assignment.day = srcItem.room_item_assignment.day
          newItem.published_room_item_assignment.save
        else
          newTimeSlot = copy(srcItem.time_slot, PublishedTimeSlot.new)
          assignment = PublishedRoomItemAssignment.new(:published_room => newRoom, 
                  :published_time_slot => newTimeSlot, 
                  :day => srcItem.room_item_assignment.day, 
                  :published_programme_item => newItem)
          assignment.save
        end

        # Put the date and the person who did the publish into the association (Publication)
        newItem.publication.publication_date = DateTime.current
        newItem.publication.user = @current_user
        newItem.publication.save
        nbrProcessed += 1
      end
    end
    return nbrProcessed
  end
  
  def updateImages(srcItem, newItem)
    # copy the images from srcItem to newItem
    newItem.external_images.delete_all # delete the old image(s)
    srcItem.external_images.each do |img|
      
      if img.picture && img.picture.url
        p = Cloudinary::Uploader.upload(img.picture.url) # copy the cloudinary remote image
        url = p['url'].partition(/upload/)[2]
        sig = p['signature']
        finalUrl = 'image/upload' +url + '#' + sig
  
        newimg = newItem.external_images.new :use => img.use, :picture => finalUrl
        newimg.save
      end
      
    end
  end
  
  def updateLinks(srcItem, newItem)
    # 1. Get the list for deletion
    # 2. Get the list for addition
    
    src_doc_ids = srcItem.linked.collect{|l| l.document_id}.compact
    dest_doc_ids = newItem.linked.collect{|l| l.document_id}.compact
    
    for_delete = dest_doc_ids - src_doc_ids
    for_add = src_doc_ids - dest_doc_ids

    newItem.linked.each do |link|
      link.delete if (for_delete.include? link.document_id)
    end

    for_add.each do |doc_id|
      new_link = Link.new
      new_link.linkedto_type = newItem.class.name
      new_link.linkedto_id = newItem.id
      new_link.document_id = doc_id
      new_link.save
    end
  end
  
  def publishRooms(rooms)
    # We have a set of rooms that have name change or similar, so we need to republish them
    nbrProcessed = 0
    # Room.uncached do
      rooms.each do |srcRoom|
        pubRoom = srcRoom.published
        if pubRoom
          pubRoom.name = srcRoom.name
          pubRoom.sort_order = srcRoom.sort_order

          pubRoom.touch
          pubRoom.save
          nbrProcessed += pubRoom.published_programme_items.size
        end
      end
    # end
    
    return nbrProcessed
  end

  def publishRoom(srcRoom)
    # 1. find out if the room is already published
    pubRoom = srcRoom.published
    
    # 2. if not then publish it
    if ! pubRoom
      pubRoom = PublishedRoom.new
      pubRoom.name = srcRoom.name
      pubRoom.sort_order = srcRoom.sort_order
      pubRoom.original = srcRoom
      pubRoom.publication.publication_date = DateTime.current
      pubRoom.publication.user = @current_user

      # we will need the venues as well
      pubVenue = publishVenue(srcRoom.venue)
      pubRoom.published_venue = pubVenue
      
      pubRoom.save
    else
      # If the room is published check to see if there is a name change/update that needs to be pushed out
      if srcRoom.updated_at > pubRoom.updated_at
        pubRoom.name = srcRoom.name
        pubRoom.sort_order = srcRoom.sort_order
        pubRoom.save
      end
    end
    
    return pubRoom
  end
  
  def publishVenue(srcVenue)
    pubVenue = srcVenue.published
    
    if !pubVenue
      pubVenue = PublishedVenue.new
      pubVenue.name = srcVenue.name
      pubVenue.sort_order = srcVenue.sort_order
      pubVenue.original = srcVenue
      pubVenue.publication.publication_date = DateTime.current
      pubVenue.publication.user = @current_user
      
      pubVenue.save
    else # check for update (such as name)
      if srcVenue.updated_at > pubVenue.updated_at
        pubVenue.name = srcVenue.name
        pubVenue.sort_order = srcVenue.sort_order
        pubVenue.save
      end
    end
    
    return pubVenue
  end
  
  #
  # Update the assignments of people from the unpublished item to the published item
  #
  def updateAssignments(src, dest)
    if src.programme_item_assignments
      src.programme_item_assignments.each do |srcAssignment|
        # add the person only if the destination does not have that person
        if (dest.people == nil) || (dest.people.index(srcAssignment.person) == nil)
          # check their role for reserved, if reserved then we do not want that person published
          if (srcAssignment.role != PersonItemRole['Reserved']  && srcAssignment.role != PersonItemRole['Invisible'] )
            assignment = dest.published_programme_item_assignments.new(:person => srcAssignment.person, :role => srcAssignment.role, :person_name => srcAssignment.person.getFullPublicationName)
            assignment.save
          end
        else # the destination has the person, but their role may have changed
          # find the index of the person only if the role is also different
          idx = dest.published_programme_item_assignments.index{ |a| (a.person == srcAssignment.person) && (a.role != srcAssignment.role) }
          if idx != nil
            if (srcAssignment.role == PersonItemRole['Reserved']) || (srcAssignment.role == PersonItemRole['Invisible'])
              # If the role is changed to reserved or invisible then they should be removed...
              dest.published_programme_item_assignments[idx].destroy
            else  
              dest.published_programme_item_assignments[idx].role = srcAssignment.role
              dest.published_programme_item_assignments[idx].save
            end
          end
        end
      end
      
      # if the destination has a person that the source does not then we need to remove that assignment
      dest.published_programme_item_assignments.each do |pitem|
        if (src.people.index(pitem.person) == nil)
          pitem.destroy
        end
      end
    else # since there are no source assignments we should then remove all the destination assignments (if there are any)
      if dest.published_programme_item_assignments
        dest.published_programme_item_assignments.destroy
      end
    end
  end
  
  #
  # Copy the attributes from the source that have an equivalent in the destination
  #
  def copy(src, dest)
    src.attributes.each do |name, val|
      # but do not copy any of the variables needed for the optimistic locking, the id, etc
      if (dest.attributes.key? name) && (["lock_version", "created_at", "updated_at", "id", "pub_reference_number", "conference_id", "linkedto_type", "linkedto_id"].index(name) == nil)
        # Only copy values that have changed?
        dest.send("#{name}=",val) if (dest.attributes[name] == nil) || (dest.attributes[name] != val) || (val != nil)
      end
    end
    
    return dest
  end

  def load_cloudinary_config
    cfg = CloudinaryConfig.find :first
    Cloudinary.config do |config|
      config.cloud_name           = cfg ? cfg.cloud_name : ''
      config.api_key              = cfg ? cfg.api_key : ''
      config.api_secret           = cfg ? cfg.api_secret : ''
      config.enhance_image_tag    = cfg ? cfg.enhance_image_tag : false
      config.static_image_support = cfg ? cfg.static_image_support : false
     config.cdn_subdomain = true
    end
  end
  
  def copyTags(from, to)
    # need to get all tags except admin
    taggings = ActsAsTaggableOn::Tagging.find :all,
                  :select => "DISTINCT(context)",
                  :conditions => "taggable_type like '" + from.class.name + "' AND context != 'Admin'"
    
    taggings.each do |tagging|
      tags = from.tag_list_on(tagging.context)
      tagstr = tags * ","
      if tags
        to.set_tag_list_on(tagging.context, tagstr)
      end
    end
  end

end
