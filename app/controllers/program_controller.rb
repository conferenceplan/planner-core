#
#
#
class ProgramController < ApplicationController

  #
  # Set up the cache for the published data. This is so we do not need to hit the DB everytime someone request the published programme grid.
  # For now we only have the cached objects around for 10 minutes. Which means that when the publish has been done within 10 minutes folks
  # will see the new data...
  #
  caches_action :participants, #:expires_in => 10.minutes,
                :cache_path => Proc.new { |c| c.params.delete_if { |k,v| k.starts_with?('sort')  || k.starts_with?('_dc') || k.starts_with?('undefined')} }#,
#                :unless => Proc.new { |c| c.params.has_key?('callback') }
  caches_action :index, #:expires_in => 10.minutes,
                :cache_path => Proc.new { |c| c.params.delete_if { |k,v| k.starts_with?('sort')  || k.starts_with?('_dc') || k.starts_with?('undefined')} }#,
#                :unless => Proc.new { |c| c.params.has_key?('callback') }
  
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
      format.js {
        render :json => "var program = " + @programmeItems.to_json(:new_format => true) + ";", :content_type => 'application/javascript' 
      }
      format.json {
        if params[:func]
          render :json => "var "+ params[:func] +" = " + @programmeItems.to_json(:new_format => true) + ";", :content_type => 'application/javascript' 
        else  
          render :json => @programmeItems.to_json(:new_format => true), :callback => params[:callback], :content_type => 'application/json'
        end
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
           csv_string = CSV.generate do |csv|
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
      format.json { 
          if params[:func]
            render :json => "var "+ params[:func] +" = " + @rooms.to_json(:except => [:created_at , :updated_at, :lock_version, :published_venue_id],
                                                   :include => [:published_venue]
            ), :content_type => 'application/json', :callback => params[:callback] 
          else  
            render :json => @rooms.to_json(:except => [:created_at , :updated_at, :lock_version, :published_venue_id],
                                                   :include => [:published_venue]
            ), :content_type => 'application/json', :callback => params[:callback] 
          end
        }
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
  
  #
  #
  #
  def participants
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.js { 
          @participants = ActiveRecord::Base.connection.select_rows(PARTICIPANT_QUERY)
          jsonstr = participants_to_json(@participants)
          render :json => "var participants = " + jsonstr + ";", :content_type => 'application/javascript' 
      }
      format.json {
          @participants = ActiveRecord::Base.connection.select_rows(PARTICIPANT_QUERY)
          jsonstr = participants_to_json(@participants)
          if params[:func]
            render :json  => "var "+ params[:func] +" = " + jsonstr, :content_type => 'application/json', :callback => params[:callback]
          else  
            render_json  jsonstr, :content_type => 'application/json', :callback => params[:callback]
          end
      }
      format.csv {
          @participants = ActiveRecord::Base.connection.select_rows(PARTICIPANT_QUERY_PLAIN)
           csv_string = CSV.generate do |csv|
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
            jsonstr += '{"id":"' + p[0].to_s  + '"'
            jsonstr += ',"name": [' + p[1].to_json + ',' + p[2].to_json # first, last, prefix, suffix
            jsonstr += ', "",' + p[3].to_json if !p[3].empty?
            jsonstr += ']' 
            jsonstr += ',"tags": []' # Add tags - TODO 
            jsonstr += ',"links": {'
            
            linksstr = ""
            linksstr += '"photo":' + p[8].to_json if !p[8].empty?
            linksstr += "," if !linksstr.empty? if !p[8].empty?
            linksstr += '"url":' + p[5].to_json if !p[5].empty?
            linksstr += "," if !linksstr.empty? && !p[5].empty?
            linksstr += '"twitter":' + p[6].to_json if !p[6].empty?
            linksstr += "," if !linksstr.empty? && !p[6].empty?
            linksstr += '"fb":' + p[7].to_json if !p[7].empty?
            
            jsonstr += linksstr + '}'
            jsonstr += ',"bio":' + p[4].to_json 
            jsonstr += ',"prog": '
            jsonstr += p[9] ? p[9].split(",").to_json : '[]' # Add progam ids if any 
            jsonstr += '}'
          end
          jsonstr = '[' + jsonstr + ']'
          if params[:func]
            render :json  => "var "+ params[:func] +" = " + jsonstr, :content_type => 'application/json', :callback => params[:callback]
          else  
            render :json  => jsonstr, :content_type => 'application/json', :callback => params[:callback]
          end
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
  
  #
  #
  #
  def updateSelect
    @pubDateList = PublicationDate.all(:order => "created_at DESC")
  end
  
  #
  #
  #
  def publicationDates
    pubDates = PublicationDate.all
    res = []
    
    if pubDates
      pubDates.each do |v|
        res << {
          :date => v.created_at,
          :id => v.id,
          :new => v.newitems,
          :updates => v.modifieditems,
          :removed => v.removeditems
        }
      end
    end
    
    respond_to do |format|
      format.json {
        if params[:func]
          render :json => "var "+ params[:func] +" = " + res.to_json, :callback => params[:callback] 
        else  
          render :json => res, :content_type => 'application/json', :callback => params[:callback]
        end
      }
    end
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
    
    @resultantChanges = PublishedProgramItemsService.getUpdatesFromPublishDate(@lastPubDate)
    
    ActiveRecord::Base.include_root_in_json = false # hack for now
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.atom # for an Atom feed (for readers)
      format.json {
        jsonstr = ""
        jsonstr += '{"new":' + @resultantChanges[:new].keys.collect { |v| v }.to_json(:new_format => true) + "}" if @resultantChanges[:new]
        jsonstr += ',' if @resultantChanges[:removeItem] && !jsonstr.empty? 
        jsonstr += '{"removed":' + @resultantChanges[:removeItem].keys.to_json() + "}" if @resultantChanges[:removeItem]
         
        if (@resultantChanges[:update] || @resultantChanges[:removePerson] ||  @resultantChanges[:addPerson] || @resultantChanges[:detailUpdate])
          list = []
          jsonstr += ',' if !jsonstr.empty?
          jsonstr += '{"updates":' 
          
          list = list.concat @resultantChanges[:update].keys if @resultantChanges[:update]
          list = list.concat @resultantChanges[:detailUpdate].keys if @resultantChanges[:detailUpdate]
          
          jsonstr += list.uniq{|v| v[:id]}.to_json(:new_format => true) 
          jsonstr += "}"
        end
        
        # now the add and remove people
        jsonstr += ',' if @resultantChanges[:removePerson] && !jsonstr.empty? 
        jsonstr += '{"peopleRemoved":' + @resultantChanges[:removePerson].values.collect {|x| x[0]}.to_json({:terse => true}) + "}" if @resultantChanges[:removePerson]
        jsonstr += ',' if @resultantChanges[:addPerson] && !jsonstr.empty? 
        jsonstr += '{"peopleAdded":' + @resultantChanges[:addPerson].values.collect {|x| x[0]}.to_json({:terse => true}) + "}" if @resultantChanges[:addPerson]
        
        if params[:func]
          render :json  => "var "+ params[:func] +" = [" + jsonstr + "]", :content_type => 'application/json' #  
        else  
          render :json  => "[" + jsonstr + "]", :content_type => 'application/json', :callback => params[:callback] #  
        end
      }
    end
  end
  
  def updates2
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
    
    @resultantChanges = PublishedProgramItemsService.getUpdatesFromPublishDate(@lastPubDate)
    
    ActiveRecord::Base.include_root_in_json = false # hack for now
        newItems = []
        updates = {}
        if @resultantChanges[:new]
          @resultantChanges[:new].each do |k, v|
            if !updates[k.id]
              updates[k.id] = {}
            end
            logger.debug "***** " + k.id.to_s
            logger.debug "***** " + k.to_s
            updates[k.id] = k
            newItems << k.id
          end  
        end
        
        if @resultantChanges[:update]
          @resultantChanges[:update].each do |k, v|
            if !updates[k.id]
              updates[k.id] = {}
            end
            if v[:timeMove]
              updates[k.id].merge!( { 'date' => v[:timeMove][1].strftime('%Y-%m-%d') } ) if updates[k.id].is_a? Hash 
              updates[k.id].merge!( { 'time' => v[:timeMove][1].strftime('%H:%M') } ) if updates[k.id].is_a? Hash 
            end
            if v[:roomMove]
            logger.debug "***** " + k.id.to_s #v[:roomMove][1].name
              updates[k.id].merge!( { 'loc' => [v[:roomMove][1].name, v[:roomMove][1].published_venue.name] } ) if updates[k.id].is_a? Hash 
            logger.debug "******"
            end
          end
        end
        
        # # detailUpdates = {} # Create an association to put in the update information
        if @resultantChanges[:detailUpdate]
          # Go through the changes and add them to an association of changes...
          @resultantChanges[:detailUpdate].each do |k, v|
            if v.size > 0 && v.kind_of?(Array) && !newItems.index(k.id)
                v.each do |change|
                  change.each do |name, vals|
                    if vals
                      if name != "pub_reference_number"
                        if !updates[k.id]
                          updates[k.id] = {}
                        end
                        name = 'desc' if name == 'precis'
                        updates[k.id].merge!( { name => vals[1].to_s } )
                      end
                    end
                  end
                end
            end
          end
        end
        
        if @resultantChanges[:removeItem]
          @resultantChanges[:removeItem].each do |k,v|
            if !updates[k.id]
              updates[k.id] = {}
            end
            updates[k.id] = false
          end
        end
        
        # Now need to deal with add person and remove person (for item and people lists)
        # @resultantChanges[:addPerson] @resultantChanges[:removePerson]
        peopleChanges = {}
        pChanges = nil
        if (@resultantChanges[:addPerson] != nil) || (@resultantChanges[:removePerson] != nil)
          pChanges = @resultantChanges[:removePerson] if @resultantChanges[:removePerson] != nil
          if (@resultantChanges[:addPerson] != nil)
            pChanges = (pChanges != nil) ? (pChanges.merge @resultantChanges[:addPerson]) : @resultantChanges[:addPerson]
          end
          pChanges.each do |k,v|
            if !updates[k.id]
              updates[k.id] = {}
            end
            updates[k.id] = { 'people' =>  k.people.collect{ |p| { 
                                              :id => p.id.to_s , 
                                              :name => p.getFullPublicationName.strip
                                                }
                                            }
            }

            v.each_index do |idx|
              if (idx % 2 == 0) && v[idx].instance_of?( Person )
                peopleChanges[v[idx].id] = v[idx]
              end
            end
          end  
        end  
        
        jsonstr = ""
        jsonstr += '{'
        jsonstr += '"program" : '
        jsonstr += updates.to_json(:new_format => true)
        jsonstr += ',"people" : '
        jsonstr += peopleChanges.to_json(:terse => true)
        jsonstr += '}'
                
    respond_to do |format|
      format.js {
        render :json => "var updates = " + jsonstr + ";", :content_type => 'application/javascript' 
      }
      format.json {
        if params[:func]
          render :json  => "var "+ params[:func] +" = [" + jsonstr + "]", :content_type => 'application/json' #  
        else  
          render :json  => "" + jsonstr + "", :content_type => 'application/json', :callback => params[:callback] #  
        end
      }
    end
  end
  
  protected
  #
  #
  #
  def participants_to_json(participants)
          jsonstr = '' 
          participants.each do |p|
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
            linksstr += "," if !linksstr.empty? if !p[5].empty?
            linksstr += '"url":' + p[5].to_json if !p[5].empty?
            linksstr += "," if !linksstr.empty? && !p[6].empty?
            linksstr += '"twitter":' + p[6].to_json if !p[6].empty?
            linksstr += "," if !linksstr.empty? && !p[7].empty?
            linksstr += '"fb":' + p[7].to_json if !p[7].empty?
            
            jsonstr += linksstr + '}'
            jsonstr += ',"bio":' + p[4].to_json 
            jsonstr += ',"prog": ' + p[9].split(",").to_json  # Add progam ids if any 
            jsonstr += '}'
          end
          jsonstr = '[' + jsonstr + ']'
  end
  
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
  left join published_programme_item_assignments on published_programme_item_assignments.person_id = people.id
  where edited_bios.bio is not null
  GROUP BY people.id
  ORDER BY last_name;
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
