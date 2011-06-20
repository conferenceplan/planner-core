class ProgramController < ApplicationController
  
  #
  # Get the full programme
  # If the day is specified then just return the items for that day
  # Can return formatted as an Atom feed or plain HTML
  #
  def index
    day = params[:day] # Day
    name = params[:name]
    conditionStr = ''
    
    conditionStr += 'published_room_item_assignments.day = ? ' if day
    conditionStr += ' AND ' if day && name
    conditionStr += 'people.last_name like ? OR people.first_name like ? ' if name
    conditions = [conditionStr] if day || name
    conditions += [day] if day
    conditions += ['%'+name+'%', '%'+name+'%'] if name
    
    @rooms = PublishedRoom.all(:order => 'published_venues.name DESC, published_rooms.name ASC', :joins => :published_venue)
    @assignments = PublishedRoomItemAssignment.all(:include => [{:published_room => [:published_venue]}, :published_time_slot, {:published_programme_item => [:publication, {:people => :pseudonym}]}],
                                                   :order => 'published_time_slots.start ASC, published_venues.name DESC, published_rooms.name ASC',
                                                   :conditions => conditions)
    
    respond_to do |format|
      format.html { render :layout => 'content' } # This should generate an HTML grid
      format.atom # for an Atom feed (for readers)
    end
  end

  def list
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.atom # for an Atom feed (for readers)
    end
  end

  def stream
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.atom # for an Atom feed (for readers)
    end
  end

  def feed
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.atom # for an Atom feed (for readers)
    end
  end

  def participants
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.atom # for an Atom feed (for readers)
    end
  end

end

#SELECT `published_room_item_assignments`.`id` AS t0_r0, `published_room_item_assignments`.`published_room_id` AS t0_r1, 
#`published_room_item_assignments`.`published_programme_item_id` AS t0_r2, `published_room_item_assignments`.`published_time_slot_id` AS t0_r3, 
#`published_room_item_assignments`.`day` AS t0_r4, `published_room_item_assignments`.`created_at` AS t0_r5, 
#`published_room_item_assignments`.`updated_at` AS t0_r6, `published_room_item_assignments`.`lock_version` AS t0_r7, 
#`published_rooms`.`id` AS t1_r0, `published_rooms`.`published_venue_id` AS t1_r1, `published_rooms`.`name` AS t1_r2, 
#`published_rooms`.`created_at` AS t1_r3, `published_rooms`.`updated_at` AS t1_r4, `published_rooms`.`lock_version` AS t1_r5, `published_venues`.`id` AS t2_r0, 
#`published_venues`.`name` AS t2_r1, `published_venues`.`created_at` AS t2_r2, `published_venues`.`updated_at` AS t2_r3, 
#`published_venues`.`lock_version` AS t2_r4, `published_time_slots`.`id` AS t3_r0, `published_time_slots`.`start` AS t3_r1, 
#`published_time_slots`.`end` AS t3_r2, `published_time_slots`.`created_at` AS t3_r3, `published_time_slots`.`updated_at` AS t3_r4, 
#`published_time_slots`.`lock_version` AS t3_r5, `published_programme_items`.`id` AS t4_r0, `published_programme_items`.`short_title` 
#AS t4_r1, `published_programme_items`.`title` AS t4_r2, `published_programme_items`.`precis` AS t4_r3, 
#`published_programme_items`.`duration` AS t4_r4, `published_programme_items`.`created_at` AS t4_r5, 
#`published_programme_items`.`updated_at` AS t4_r6, `published_programme_items`.`lock_version` AS t4_r7, 
#`published_programme_items`.`format_id` AS t4_r8 FROM `published_room_item_assignments` 
#LEFT OUTER JOIN `published_rooms` ON `published_rooms`.id = `published_room_item_assignments`.published_room_id 
#LEFT OUTER JOIN `published_venues` ON `published_venues`.id = `published_rooms`.published_venue_id 
#LEFT OUTER JOIN `published_time_slots` ON `published_time_slots`.id = `published_room_item_assignments`.published_time_slot_id 
#LEFT OUTER JOIN `published_programme_items` ON `published_programme_items`.id = `published_room_item_assignments`.published_programme_item_id 
#ORDER BY published_time_slots.start ASC, published_rooms.name
