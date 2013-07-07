#
#
#
class ProgramController < ApplicationController

  #
  # Set up the cache for the published data. This is so we do not need to hit the DB everytime someone request the published programme grid.
  # For now we only have the cached objects around for 10 minutes. Which means that when the publish has been done within 10 minutes folks
  # will see the new data...
  #
  caches_action :participants, :expires_in => 10.minutes,
                :cache_path => Proc.new { |c| c.params.delete_if { |k,v| k.starts_with?('sort')  || k.starts_with?('_dc') || k.starts_with?('undefined')} }#,
#                :unless => Proc.new { |c| c.params.has_key?('callback') }
  caches_action :index, :expires_in => 10.minutes,
                :cache_path => Proc.new { |c| c.params.delete_if { |k,v| k.starts_with?('sort')  || k.starts_with?('_dc') || k.starts_with?('undefined')} }#,
#                :unless => Proc.new { |c| c.params.has_key?('callback') }
  # TODO - put in an observer that clears the cache when a new publish has been done
  
  #
  # Get the full programme
  # If the day is specified then just return the items for that day
  # Can return formatted as an Atom feed or plain HTML
  #
  def index
    stream = params[:stream]
    layout = params[:layout]
    day = params[:day]
    conditions = getConditions(params)
    
    @rooms = PublishedRoom.all(:select => 'distinct published_rooms.name',
                               :order => 'published_venues.name DESC, published_rooms.name ASC', 
                               :include => [:published_venue, {:published_room_item_assignments => {:published_programme_item => {:people => :pseudonym}}}],
                               :conditions => conditions)
    
    if stream
      @programmeItems = PublishedProgrammeItem.tagged_with( stream, :on => 'PrimaryArea', :op => true).all(
                                                 :include => [:publication, :published_time_slot, :published_room_item_assignment, {:people => [:pseudonym, :edited_bio]}, {:published_room => [:published_venue]} ],
                                                 :order => 'published_time_slots.start ASC, published_venues.name DESC, published_rooms.name ASC',
                                                 :conditions => conditions)
    else
      @programmeItems = PublishedProgrammeItem.all(:include => [:publication, :published_time_slot, :published_room_item_assignment, {:people => [:pseudonym, :edited_bio]}, {:published_room => [:published_venue]} ],
                                                 :order => 'published_time_slots.start ASC, published_venues.name DESC, published_rooms.name ASC',
                                                 :conditions => conditions)
    end
    
    ActiveRecord::Base.include_root_in_json = false # hack for now
     
    respond_to do |format|
      format.html { 
        if layout && layout == 'line'
          render :action => :list, :layout => 'content' 
        else  
          render :layout => 'content' 
        end
      } # This should generate an HTML grid
      format.atom # for an Atom feed (for readers) TODO - need to check were the domain for the Bio URL is set and fix
      format.js {
        render :json => @programmeItems, :callback => params[:callback]
      }
      format.json {
        render :json => @programmeItems.to_json(:new_format => true), :callback => params[:callback]
      }
    end
  end
  
  def grid
    @rooms = PublishedRoom.all(:select => 'distinct published_rooms.name',
      :order => 'published_venues.name DESC, published_rooms.name ASC', :include => [:published_venue]) #,

    @programmeItems = PublishedProgrammeItem.all(:include => [:publication, :published_time_slot, :published_room_item_assignment, {:published_room => [:published_venue]} ],
      :order => 'published_time_slots.start ASC, published_venues.name DESC, published_rooms.name ASC')

    respond_to do |format|
      format.csv {
           csv_string = FasterCSV.generate do |csv|
             csv << ["", @rooms.collect{|e| e.name}].flatten # first row is the list of rooms

             currentColumn = 1
             line = prevline = []
             prevTime = nil
             @programmeItems.each do |item|
               # if time is the same then keep on one row...
               currentTime = item.published_time_slot.start
               
               if ((prevTime != nil) && (currentTime != prevTime))
                 # we output the line and then start the new line
                 if prevline != nil
                   nl = mergeTimeLines(line, prevline, prevTime)
                   csv << [prevTime.strftime('%Y %B %d %H:%M'), nl.collect{|e| (e.is_a? PublishedProgrammeItem) ? e.title : e }].flatten
                 else
                   csv << [prevTime.strftime('%Y %B %d %H:%M'), line.collect{|e| (e.is_a? PublishedProgrammeItem) ? e.title : e }].flatten
                 end
                 
                 if prevTime + 30.minutes < currentTime # insert an extra line
                   nl = mergeTimeLines(line, prevline, prevTime+ 30.minutes)
                   csv << [(prevTime+ 30.minutes).strftime('%Y %B %d %H:%M'), nl.collect{|e| (e.is_a? PublishedProgrammeItem) ? e.title : e }].flatten
                 end
                 
                 prevline = nl
                 line =[]
                 currentColumn = 1
               end

               # fill up the current line               
               idx = @rooms.index{|x| (item.published_room != nil) && (x.name == item.published_room.name)} # get column that the current item's room is in
               if idx
                 (currentColumn..idx).each do |i|
                   line << ""
                 end
                 currentColumn = idx + 2
               end
               line << item

               prevTime = currentTime
             end
                 csv << [prevTime.strftime('%Y %B %d %H:%M'), line.collect{|e| (e.is_a? PublishedProgrammeItem) ? e.title : e }].flatten
           end
           send_data csv_string, :type => 'text/csv; charset=iso-8859-1; header=present'
      }
      format.html {
          render :layout => 'content' 
      }
    end

  end
  
  #
  # Return a list of rooms - use the same parameters as for the grid
  #
  def rooms
    conditions = getConditions(params)
    
    @rooms = PublishedRoom.all(:select => 'distinct published_rooms.name',
                               :order => 'published_venues.name DESC, published_rooms.name ASC', 
                               :include => [:published_venue, {:published_room_item_assignments => {:published_programme_item => {:people => :pseudonym}}}],
                               :conditions => conditions)
    
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.js { render_json @rooms.to_json(:except => [:created_at , :updated_at, :lock_version, :published_venue_id],
                                                 :include => [:published_venue]
        ), :content_type => 'application/json' }
    end
  end
  
  #
  # Return a list of the programme streams
  #
  def streams
    tags = PublishedProgrammeItem.tag_counts_on( 'PrimaryArea' )
    
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.js { render_json tags.to_json(
                                    :except => [:created_at , :updated_at, :lock_version, :id, :count]
        ), :content_type => 'application/json' }
    end
  end
  
  def participants
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.js { 
          @participants = ActiveRecord::Base.connection.select_rows(PARTICIPANT_QUERY)
          jsonstr = '' 
          @participants.each do |p|
            if jsonstr.length > 0
              jsonstr += ','
            end
            jsonstr += '{"id":"' + p[0] + '","first_name":' + p[1].to_json + ',"last_name":' + p[2].to_json + ',"suffix":' + p[3].to_json
            jsonstr += ',"bio":' + p[4].to_json 
            jsonstr += ',"website":' + p[5].to_json +  ',"twitterinfo":' 
            jsonstr += p[6].to_json +  ',"facebook":' + p[7].to_json + '}'
          end
          jsonstr = '[' + jsonstr + ']'
          render_json  jsonstr, :content_type => 'application/json'
        }
      format.json {
          @participants = ActiveRecord::Base.connection.select_rows(PARTICIPANT_QUERY)
          jsonstr = '' 
          @participants.each do |p|
            if jsonstr.length > 0
              jsonstr += ','
            end
            jsonstr += '{"id":"' + p[0]  + '"'
            jsonstr += ',"name": [' + p[1].to_json + ',' + p[2].to_json # first, last, prefix, suffix
            jsonstr += ', "",' + p[3].to_json if !p[3].empty?
            jsonstr += ']' 
            jsonstr += ',"tags": []' # Add tags - TODO 
            jsonstr += ',"links": {'
            
            linksstr = ""
            linksstr += '"photo":' + p[8].to_json if !p[8].empty?
            linksstr += "," if !linksstr.empty?
            linksstr += '"url":' + p[5].to_json if !p[5].empty?
            linksstr += "," if !linksstr.empty? && !p[5].empty?
            linksstr += '"twitter":' + p[6].to_json if !p[6].empty?
            linksstr += "," if !linksstr.empty? && !p[6].empty?
            linksstr += '"fb":' + p[7].to_json if !p[7].empty?
            
            jsonstr += linksstr + '}'
            jsonstr += ',"bio":' + p[4].to_json 
            jsonstr += ',"prog": ' + p[9].split(",").to_json  # Add progam ids if any - TODO 
            jsonstr += '}'
          end
          jsonstr = '[' + jsonstr + ']'
          render_json  jsonstr, :content_type => 'application/json'
      }
      format.csv {
          @participants = ActiveRecord::Base.connection.select_rows(PARTICIPANT_QUERY_PLAIN)
           csv_string = FasterCSV.generate do |csv|
             @participants.each do |n|
                csv << [ n[0], n[1], n[2], n[3], BlueCloth.new(n[4]).to_html]
             end
           end
           send_data csv_string, :type => 'text/csv; charset=iso-8859-1; header=present'
        }
    end
  end  
  
  #
  # Return the participants and their Bios
  #
  def participants_and_bios
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.json { 
          @participants = ActiveRecord::Base.connection.select_rows(PARTICIPANT_WITH_BIO_QUERY)
          jsonstr = ''
          @participants.each do |p|
            if jsonstr.length > 0
              jsonstr += ','
            end
            jsonstr += '{"id":"' + p[0]  + '"'
            jsonstr += ',"name": [' + p[1].to_json + ',' + p[2].to_json # first, last, prefix, suffix
            jsonstr += ', "",' + p[3].to_json if !p[3].empty?
            jsonstr += ']' 
            jsonstr += ',"tags": []' # Add tags - TODO 
            jsonstr += ',"links": {'
            
            linksstr = ""
            linksstr += '"photo":' + p[8].to_json if !p[8].empty?
            linksstr += "," if !linksstr.empty?
            linksstr += '"url":' + p[5].to_json if !p[5].empty?
            linksstr += "," if !linksstr.empty? && !p[5].empty?
            linksstr += '"twitter":' + p[6].to_json if !p[6].empty?
            linksstr += "," if !linksstr.empty? && !p[6].empty?
            linksstr += '"fb":' + p[7].to_json if !p[7].empty?
            
            jsonstr += linksstr + '}'
            jsonstr += ',"bio":' + p[4].to_json 
            jsonstr += ',"prog": ' + p[9].split(",").to_json  # Add progam ids if any - TODO 
            jsonstr += '}'
          end
          jsonstr = '[' + jsonstr + ']'
          render_json  jsonstr, :content_type => 'application/json'
        }
    end
  end  
  
  #
  # What is coming up in the next x hours
  #
  def feed
    
    start_time = Time.zone.parse(SITE_CONFIG[:conference][:start_date])
    if Time.now > start_time
      start_time = Time.now
    else
      start_time = Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + 9.hours
    end

    end_time = start_time + 3.hours
    conditions = ["(published_time_slots.start >= ?) AND (published_time_slots.start <= ?)", start_time, end_time]
    
    @programmeItems = PublishedProgrammeItem.all(:include => [:publication, :published_time_slot, :published_room_item_assignment, {:people => [:pseudonym, :edited_bio]}, {:published_room => [:published_venue]} ],
                                                 :order => 'published_time_slots.start ASC, published_venues.name DESC, published_rooms.name ASC',
                                                 :conditions => conditions)

    ActiveRecord::Base.include_root_in_json = false # hack for now
     
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.atom # for an Atom feed (for readers)
      format.js { 
        render_json @programmeItems.to_json(
        :except => [:created_at , :updated_at, :lock_version, :format_id, :end, :comments, :language,
              :acceptance_status_id, :mailing_number, :invitestatus_id, :invitation_category_id,
              :last_name, :first_name, :suffix, :pub_reference_number],
        :methods => [:shortDate, :timeString, :bio, :pub_number, :pubFirstName, :pubLastName, :pubSuffix, :twitterinfo, :website, :facebook],
        :include => {:published_time_slot => {}, :published_room => {:include => :published_venue}, :people => {:include => {:pseudonym => {}}}}
        ), :content_type => 'application/json' 
        }
    end
  end
  
  def updateSelect
    @pubDateList = PublicationDate.all(:order => "created_at DESC")
  end
  
  #
  # Report back on what has changed. This is used to generate the pink sheets.
  #
  # Item time and room changes
  # New Items
  # Dropped Items
  # Participants Added
  # Participants Dropped
  #
  # Title and Description changes
  #
  # Person add
  # Person roleChange
  # Person remove
  #
  #
  def updates
    pubIndex = params[:pubidx]
    @resultantChanges = {}
    
    # To get the updates:
    # Get a list of all publications that have changed since the last publication date
    if pubIndex
      @lastPubDate = PublicationDate.find(pubIndex)
    else
      @lastPubDate = PublicationDate.last
    end
    
    if !@lastPubDate
      return
    end
    
    audits = Audit.all(
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like ?)", @lastPubDate.timestamp, 'Published%'],
      :order => "audits.created_at asc"
    )
    
    # item, action, person, as role
    audits.each do |audit|
      if audit.action == 'destroy' # item removed
        # when an item is removed there are multiple entries in the audit table. PublishedProgrammeItemAssignment, PublishedRoomItemAssignment, PublishedTimeSlot, PublishedProgrammeItem
        # all for the one event. We need to be able to infer that this is one event and not mony...
        # All are destroy events... but we only need to know the one i.e. the programme item was destroyed
        if audit.auditable_type == "PublishedProgrammeItem"
          title = audit.changes['title']
          id = audit.auditable_id
          # need to know what the time was ....
          @resultantChanges = addPinkSheetEntryWithKey(@resultantChanges, id , :removeItem , :title, title) # TODO - add other values from the audit table provide more info i.e. dropped from day & time
        elsif audit.auditable_type == "PublishedProgrammeItemAssignment" # person was removed...
          begin
            programmeItem = PublishedProgrammeItem.find(audit.changes["published_programme_item_id"]) # this will fail
            role = PersonItemRole[audit.changes["role_id"]]
            person = Person.find(audit.changes["person_id"])
            @resultantChanges = addPinkSheetEntry(@resultantChanges, programmeItem, :removePerson, person, role)
          rescue
            # do nowt, kuldge to get round assigment destroys where programme item does not exist
          end
        elsif audit.auditable_type == 'PublishedRoomItemAssignment'
          id = audit.changes['published_programme_item_id']
          room = PublishedRoom.find(audit.changes['published_room_id'])
          timeAudit = Audit.all(
            :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like ?) AND (audits.auditable_id = ?)", 
              @lastPubDate.timestamp, 'PublishedTimeSlot%', audit.changes['published_time_slot_id']]
          )
          @resultantChanges = addPinkSheetEntryWithKey(@resultantChanges, id, :removeItem, :info, room, timeAudit[0].changes['start'])
        end # we are ignoring the destroys of the room item assignment and the timeslot... TODO - collect for information on the prog item
      else  
        if audit.auditable_type == "PublishedProgrammeItemAssignment" # person added or removed
          @resultantChanges = getPeopleChange(audit, @resultantChanges)
        elsif audit.auditable_type == "PublishedRoomItemAssignment" # item added, or moved
            @resultantChanges = getItemChange(audit, @resultantChanges)
        end
      end
    end
    
    respond_to do |format|
      format.html { render :layout => 'content' }
#################################      
#      format.atom { send_file 'public/updates', :type => 'application/atom+xml', :x_sendfile => true } # for an Atom feed (for readers)
      format.atom
    end
  end
  
  protected

  # Merge into the current line
  def mergeTimeLines(curLine, prevLine, time)
    nl = []
    
    curLine.each_index do |idx|

      if (curLine[idx].is_a? PublishedProgrammeItem) && ((curLine[idx].published_time_slot.start == time) || (curLine[idx].published_time_slot.end > time))
        nl << curLine[idx]
        next
      end
      
      if (prevLine[idx].is_a? PublishedProgrammeItem) && (prevLine[idx].published_time_slot.end > time)
        nl << prevLine[idx]
        next
      end
      
      nl << ""
    end
    
    return nl
  end
  
  def getProgrammeItemChanges(id)
    audits = Audit.all(
      :conditions => ["(audits.created_at >= ?) AND (audits.auditable_type like ?) AND (audits.auditable_id = ?)", @lastPubDate.timestamp, 'PublishedProgrammeItem', id],
      :order => "audits.created_at asc"
    )
    
    return audits
  end
  
  def getPeopleChange(auditInfo, resultantChanges)
    # Get the programme item assignments that have changed - this is the set of people
    if auditInfo.changes["published_programme_item_id"] # Add person
      begin
      programmeItem = PublishedProgrammeItem.find(auditInfo.changes["published_programme_item_id"])
      role = PersonItemRole[auditInfo.changes["role_id"]]
      person = Person.find(auditInfo.changes["person_id"])
      resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :addPerson, person, role)
      rescue  
      end
    else
      if auditInfo.changes["role_id"].kind_of?(Array) # then we have a role change
        newrole = PersonItemRole[auditInfo.changes["role_id"][1]]
        assignment = PublishedProgrammeItemAssignment.find(auditInfo.auditable_id)
        programmeItem = assignment.published_programme_item
        person = assignment.person
        if newrole != PersonItemRole['Reserved'] && newrole != PersonItemRole['Invisible']
          oldrole = PersonItemRole[auditInfo.changes["role_id"][0]]
          resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :newRole, person, oldrole, newrole)
        else
          resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :removePerson, person)
        end
      end
    end

    return resultantChanges
  end
  
  #
  #
  
  #
  # Item add
  # Item move
  #
  # { programmeItem => [action, action, action] }
  # action == {'timeMove' => [from, to]}
  # action == {'roomMove' => to}
  # action == 'add'
  #
  def getItemChange(auditInfo, resultantChanges)
    begin
    programmeItemAssignment = PublishedRoomItemAssignment.find(auditInfo.auditable_id) # get the associated program item assignment
    programmeItem = programmeItemAssignment.published_programme_item # from that we can get the program item
    if auditInfo.changes["published_time_slot_id"] # if it is a change to the time slote then we report on that
      # the time slot has changed if we have an array of changed time information and that array contains more than one value      
      movedTime = auditInfo.changes["published_time_slot_id"].kind_of?(Array) && auditInfo.changes["published_time_slot_id"].size > 1
      
      if movedTime # Item X has been rescheduled from time A to time B
        oldtime = PublishedTimeSlot.find(auditInfo.changes["published_time_slot_id"][0]) if movedTime == true
        newtime = PublishedTimeSlot.find(auditInfo.changes["published_time_slot_id"][1])
      else # 
        newtime = PublishedTimeSlot.find(auditInfo.changes["published_time_slot_id"])
      end
      
      if movedTime && newtime.start != oldtime.start # then we have move time slot
        # Item X has been rescheduled from time A to time B
        resultantChanges = addPinkSheetEntryWithKey(resultantChanges, programmeItem, :update, :timeMove, oldtime.start, newtime.start)
      else # we have moved room or added an item
        # TODO - could also be a change to one of the other attributes
        if resultantChanges[:update] && resultantChanges[:update][programmeItem]
          resultantChanges = addPinkSheetEntryWithKey(resultantChanges, programmeItem, :update, :add, newtime.start)
        end
          # If the item was update (Title etc) then it is not a new....
          # Look for the PublishedProgrammeItem and see if it is an update
          if (auditInfo.action == 'update')
            auditChange = getProgrammeItemChanges(programmeItem.id);
            if auditChange
              auditChange.each do |a|
                resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :detailUpdate, a.changes)
              end
            end
          else  
            resultantChanges = addPinkSheetEntry(resultantChanges, programmeItem, :new, newtime.start)
          end
        # Item X has been added to room B at time C
      end
    else # The item has been moved to a new venue
      # else it is an addition of the program item to the schedule
      # Item X has been added or moved to the program in room A at time B
      room = nil
      fromRoom = nil
      if auditInfo.changes['published_room_id']
        if auditInfo.changes['published_room_id'].kind_of?(Array)
          fromRoom = PublishedRoom.find(auditInfo.changes["published_room_id"][0])
          room = PublishedRoom.find(auditInfo.changes["published_room_id"][1])
        else
          room = PublishedRoom.find(auditInfo.changes["published_room_id"])
        end
      end
      resultantChanges = addPinkSheetEntryWithKey(resultantChanges, programmeItem, :update, :roomMove, room, fromRoom)
    end
    # TODO - if we have a move + add of the same item then it is a move not an add
    
    rescue
    end
    return resultantChanges
  end
  
  # Person add
  # Person roleChange
  # Person remove
  #
  # action => { programmeItem => [] }
  #
  # { programmeItem => [action, action, action] }
  # action == {'timeMove' => [from, to]}
  # action == {'roomMove' => to}
  # action == 'add'
  #
  def addPinkSheetEntry(resultCollection, programmeItem, operation, *args)
    begin
    if resultCollection[operation]
      if resultCollection[operation][programmeItem]
        resultCollection[operation][programmeItem].concat args
      else
        resultCollection[operation][programmeItem] = args
      end
    else
      resultCollection[operation] = {programmeItem => args}
    end
    
    rescue  
    end
    return resultCollection
  end
  
  def addPinkSheetEntryWithKey(resultCollection, programmeItem, operation, key, *args)
    
    if resultCollection[operation]
      if resultCollection[operation][programmeItem]
        resultCollection[operation][programmeItem][key] = args
      else
        resultCollection[operation][programmeItem] = { key => args }
      end
    else
      resultCollection[operation] = {programmeItem => {key => args}}
    end
    
    return resultCollection
  end

  def getConditions(params)
    day = params[:day] # Day
    name = params[:name]
    lastname = params[:lastname]
    
    conditionStr = "" if day || name || lastname
    conditionStr += '(published_room_item_assignments.day = ?) ' if day
    conditionStr += ' AND ' if day && (name || lastname)
    conditionStr += '(people.last_name like ? OR pseudonyms.last_name like ? OR people.first_name like ? OR pseudonyms.first_name like ? )' if name && !lastname
    conditionStr += '((people.last_name like ? OR pseudonyms.last_name like ?) AND (people.first_name like ? OR pseudonyms.first_name like ?))' if name && lastname
    conditionStr += '(people.last_name like ? OR pseudonyms.last_name like ?)' if lastname && !name
    conditions = [conditionStr] if day || name || lastname
    conditions += [day] if day 
    lastname = name if !lastname
    conditions += ['%'+lastname+'%', '%'+lastname+'%', '%'+name+'%', '%'+name+'%'] if name
    conditions += ['%'+lastname+'%', '%'+lastname+'%'] if lastname && !name
    
    return conditions
  end

#
PARTICIPANT_QUERY = <<"EOS"
  select distinct
  people.id,
  case when pseudonyms.first_name is not null AND char_length(pseudonyms.first_name) > 0 then pseudonyms.first_name else people.first_name end as first_name,
  case when pseudonyms.last_name is not null AND char_length(pseudonyms.last_name) > 0 then pseudonyms.last_name else people.last_name end as last_name,
  case when pseudonyms.suffix is not null AND char_length(pseudonyms.suffix) > 0 then pseudonyms.suffix else people.suffix end as suffix,
  IFNULL(edited_bios.bio, ''),
  IFNULL(edited_bios.website,''),
  IFNULL(edited_bios.twitterinfo,''),
  IFNULL(edited_bios.facebook,''),
  IFNULL(edited_bios.photourl,''),
  GROUP_CONCAT(published_programme_item_assignments.published_programme_item_id)
  from people
  left join pseudonyms ON pseudonyms.person_id = people.id
  left join edited_bios on edited_bios.person_id = people.id
  join published_programme_item_assignments on published_programme_item_assignments.person_id = people.id
  GROUP BY people.id
  ORDER BY people.last_name;
EOS

#
PARTICIPANT_WITH_BIO_QUERY = <<"EOS"
  select distinct
  people.id,
  case when pseudonyms.first_name is not null AND char_length(pseudonyms.first_name) > 0 then pseudonyms.first_name else people.first_name end as first_name,
  case when pseudonyms.last_name is not null AND char_length(pseudonyms.last_name) > 0 then pseudonyms.last_name else people.last_name end as last_name,
  case when pseudonyms.suffix is not null AND char_length(pseudonyms.suffix) > 0 then pseudonyms.suffix else people.suffix end as suffix,
  IFNULL(edited_bios.bio, ''),
  IFNULL(edited_bios.website,''),
  IFNULL(edited_bios.twitterinfo,''),
  IFNULL(edited_bios.facebook,''),
  IFNULL(edited_bios.photourl,''),
  GROUP_CONCAT(published_programme_item_assignments.published_programme_item_id)
  from people
  left join pseudonyms ON pseudonyms.person_id = people.id
  left join edited_bios on edited_bios.person_id = people.id
  join published_programme_item_assignments on published_programme_item_assignments.person_id = people.id
  where edited_bios.bio is not null
  GROUP BY people.id
  ORDER BY people.last_name;
EOS

#
# Use this for plain CSV with no programme information
#
PARTICIPANT_QUERY_PLAIN = <<"EOS"
  select distinct 
  case when pseudonyms.first_name is not null AND char_length(pseudonyms.first_name) > 0 then pseudonyms.first_name else people.first_name end as first_name,
  case when pseudonyms.last_name is not null AND char_length(pseudonyms.last_name) > 0 then pseudonyms.last_name else people.last_name end as last_name,
  case when pseudonyms.suffix is not null AND char_length(pseudonyms.suffix) > 0 then pseudonyms.suffix else people.suffix end as suffix,
  IFNULL(edited_bios.bio, '')
  from people
  join published_programme_item_assignments on published_programme_item_assignments.person_id = people.id
  left join pseudonyms ON pseudonyms.person_id = people.id
  left join edited_bios on edited_bios.person_id = people.id
  ORDER BY last_name;
EOS
  
end
