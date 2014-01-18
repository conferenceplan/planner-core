#
#
#
class PlannerReportsController < PlannerController
  include PlannerReportHelpers

  require 'csv'

  #
  #
  #
  def panels_with_panelists
    @fewer_than = params[:fewer_than].to_i
    @more_than = params[:more_than].to_i
    str = URI.unescape(params[:modified_since]).gsub! '+', ' '
    modified_since_str = str ? str : params[:modified_since]
    modified_since = DateTime.parse modified_since_str
    scheduled = params[:scheduled] == "true"
    format_id = params[:format_id].to_i > 0 ? params[:format_id].to_i : nil
    sort_by = params[:sort_by]
    
    @panels = PlannerReportsService.findPanelsWithPanelists sort_by, modified_since.strftime('%Y-%m-%d'), format_id, scheduled
     
    respond_to do |format|
      format.json
      format.csv {
        outfile = "panels_" + Time.now.strftime("%m-%d-%Y") + ".csv"
        output = Array.new
        output.push [
          'Ref','Title','Min People','Max People','Format','Area(s)','Start Time','End Time','Room','Venue',
          'Equipment','Participants','Moderators','Reserve','Invisible'
        ]
        
        @panels.each do |panel|
          
          count = panel.programme_item_assignments.length
          next if (@fewer_than > 0 && count >= @fewer_than)
          next if (@more_than > 0 && count <= @more_than)

          output.push [panel.pub_reference_number, panel.title, panel.minimum_people, 
            panel.maximum_people, 
            (panel.format ? panel.format.name : ''), 
            panel.taggings.collect{|t| t.context}.uniq.join(","),
            ((panel.time_slot != nil) ? panel.time_slot.start.strftime('%a %H:%M') : ''),
            ((panel.time_slot != nil) ? panel.time_slot.end.strftime('%a %H:%M') : ''),
            ((panel.room != nil) ? panel.room.name : ''),
            ((panel.room != nil) ? panel.room.venue.name : ''),
            panel.equipment_needs.collect {|e| e.equipment_type.description if e.equipment_type }.join(","),
            panel.programme_item_assignments.select{|pi| pi.role == PersonItemRole['Participant']}.collect {|p| p.person.getFullPublicationName }.join(","),
            panel.programme_item_assignments.select{|pi| pi.role == PersonItemRole['Moderator']}.collect {|p| p.person.getFullPublicationName }.join(","),
            panel.programme_item_assignments.select{|pi| pi.role == PersonItemRole['Reserved']}.collect {|p| p.person.getFullPublicationName }.join(","),
            panel.programme_item_assignments.select{|pi| pi.role == PersonItemRole['Invisible']}.collect {|p| p.person.getFullPublicationName }.join(",")
          ]
          
        end
        csv_out(output, outfile)
      }
    end
  end
 
  #
  #
  #
  def panelists_with_panels
      
    @people = PlannerReportsService.findPanelistsWithPanels params[:specific_panelists], 
                            (params[:reserved] == "true" ? [PersonItemRole['Reserved'].id] : nil), 
                            (params[:scheduled] == "true"), 
                            (params[:forprint] == "true")

    respond_to do |format|
      format.json
      format.csv {
        outfile = "panelists_" + Time.now.strftime("%m-%d-%Y") + ".csv"
        output = Array.new
        output.push ['Name','Status','Items']
        
        @people.each do |person|
          output.push [
            person.getFullPublicationName,
            person.acceptance_status.name,
            person.programmeItemAssignments.collect { |pi|
                if (pi.programmeItem)
                    (pi.programmeItem.pub_reference_number ? pi.programmeItem.pub_reference_number.to_s + ' ' : '' ) +
                    pi.programmeItem.title +
                    ' (' + pi.programmeItem.format.name + ') ' +
                    ' (' + pi.role.name + '), ' +
                    (pi.programmeItem.time_slot ? pi.programmeItem.time_slot.start.strftime('%a %H:%M') + ' - ' + pi.programmeItem.time_slot.end.strftime('%H:%M') : '') +
                    (pi.programmeItem.room ? ', ' + pi.programmeItem.room.name : '') +
                    (pi.programmeItem.room ? ' (' + pi.programmeItem.room.venue.name + ')': '')
                end
            }.reject { |c| c == nil }.join("\n")
          ]
        end
        csv_out(output, outfile)
      }
    end
  end
  
  #
    # @names_only = params[:names_only] ? true : false
    # @names_city_only = params[:names_and_city] ? true : false
  # Need to get participant details (status, addresses etc)
  # TODO - add this report


  #
  #
  #
  def admin_tags_by_context
    
    @peopleAndTags = PlannerReportsService.findTagsByContext params[:context]
    
    respond_to do |format|
      format.json
      format.csv {
        outfile = "people_and_tags_" + params[:context] + "_" + Time.now.strftime("%m-%d-%Y") + ".csv"
        output = Array.new
        output.push ['Name', 'Tags']
        @peopleAndTags.each do |p|
          output.push [
            p.getFullPublicationName, p.details
          ]
        end
        csv_out(output, outfile)
      }
    end
  end

  #
  #
  #
  def people_by_tag

    @taginfo = PlannerReportsService.findPeopleByTag

    respond_to do |format|
      format.json
      format.csv {
        outfile = "people_by_tags_" + Time.now.strftime("%m-%d-%Y") + ".csv"
        output = Array.new
        output.push ['Context', 'Tag', 'People']
        @taginfo.each do |p|
          output.push [
            p[0][0], p[0][1],
            p[1].collect { |t| 
                if (t['pub_first_name'] || t['pub_last_name'])
                    t['pub_first_name'] + ' ' + t['pub_last_name'] + ' ' + t['pub_suffix']
                else
                    t['first_name'] + ' ' + t['last_name'] + ' ' + t['suffix']
                end
              }.join("\n")
          ]
        end
        csv_out(output, outfile)
      }

    end
  end
  
  #
  #
  #
  def panels_by_room
    
    @rooms = PlannerReportsService.findPanelsByRoom
    
    respond_to do |format|
      format.json
      format.csv {
        outfile = "panels_by_room" + Time.now.strftime("%m-%d-%Y") + ".csv"
        output = Array.new
        output.push ['Room', 'Venue', 'Item', 'Day', 'Time', 'Equipment']
        
        @rooms.collect {|r| r.programme_items.collect {|i| { :room => r, :item => i } } }.flatten.each do |e|
          output.push [
            e[:room].name,
            e[:room].venue.name,
            e[:item].title,
            e[:item].time_slot.start.strftime('%a'),
            e[:item].time_slot.start.strftime('%H:%M') + ' - ' + e[:item].time_slot.end.strftime('%H:%M'),
            e[:item].equipment_needs.collect {|eq| eq.equipment_type.description if eq.equipment_type }.join("\n")
          ]
        end
        csv_out(output, outfile)
      }
    end
    
  end

  #
  #
  #
  def panels_by_timeslot
    
    @times = PlannerReportsService.findPanelsByTimeslot
    
    respond_to do |format|
      format.json
      format.csv {
        outfile = "panels_by_timeslot" + Time.now.strftime("%m-%d-%Y") + ".csv"
        output = Array.new
        output.push ['Day', 'Time', 'Room', 'Venue', 'Item', 'Equipment']
        
        @times.collect {|t| t.programme_items.collect {|i| { :time => t, :item => i } } }.flatten.each do |e|
          output.push [
            e[:time].start.strftime('%a'),
            e[:time].start.strftime('%H:%M') + ' - ' + e[:time].end.strftime('%H:%M'),
            e[:item].room.name,
            e[:item].room.venue.name,
            e[:item].title,
            e[:item].equipment_needs.collect {|eq| eq.equipment_type.description if eq.equipment_type }.join("\n")
          ]
        end
        csv_out(output, outfile)
      }
      
    end
    
  end
  
  #
  #
  #
  def program_book_report

    @times = PlannerReportsService.findProgramItemsByTimeAndRoom
    @rooms = Room.all :select => 'distinct rooms.name',
                               :order => 'venues.name DESC, rooms.name ASC', 
                               :include => :venue
    
    respond_to do |format|
      format.xml {
        response.headers['Content-Disposition'] = 'attachment; filename="program_' + Time.now.strftime("%m-%d-%Y") + '.xml"'
      }
      format.pdf {
        response.headers['Content-Disposition'] = 'attachment; filename="program_' + Time.now.strftime("%m-%d-%Y") + '.pdf"'
      }
      format.xlsx{
        response.headers['Content-Disposition'] = 'attachment; filename="program_' + Time.now.strftime("%m-%d-%Y") + '.xlsx"'
      }
    end

  end
  
  #
  #
  #
  def table_tents
    peopleList = (params[:people].length > 0) ? URI.unescape(params[:people]).split(',') : nil
    
    @people = PlannerReportsService.findPublishedPanelistsWithPanels peopleList
    
    respond_to do |format|
      format.xml {
        response.headers['Content-Disposition'] = 'attachment; filename="table_tent_' + Time.now.strftime("%m-%d-%Y") + '.xml"'
      }
      format.pdf {
        response.headers['Content-Disposition'] = 'attachment; filename="table_tent_' + Time.now.strftime("%m-%d-%Y") + '.pdf"'
      }
      format.xlsx{
        response.headers['Content-Disposition'] = 'attachment; filename="table_tent_' + Time.now.strftime("%m-%d-%Y") + '.xlsx"'
      }
    end
  end
  
  #
  #
  #
  def badge_labels
    peopleList = (params[:people].length > 0) ? URI.unescape(params[:people]).split(',') : nil
    additional_roles = params[:additional_roles] ? PersonItemRole['Invisible'].id : nil
    for_print = params[:for_print] ? (params[:for_print] == true) : false
    
    # Only use the scheduled items
    @people = PlannerReportsService.findPanelistsWithPanels peopleList, additional_roles, true, for_print
    
    respond_to do |format|
      format.xml {
        response.headers['Content-Disposition'] = 'attachment; filename="badge_labels_' + Time.now.strftime("%m-%d-%Y") + '.xml"'
      }
      format.pdf {
        response.headers['Content-Disposition'] = 'attachment; filename="badge_labels_' + Time.now.strftime("%m-%d-%Y") + '.pdf"'
      }
      format.xlsx{
        response.headers['Content-Disposition'] = 'attachment; filename="badge_labels_' + Time.now.strftime("%m-%d-%Y") + '.xlsx"'
      }
    end
  end


  #--------------------

   def BackOfBadge
      accepted = AcceptanceStatus.find_by_name("Accepted")
      probable = AcceptanceStatus.find_by_name("Probable")
      reserved = PersonItemRole.find_by_name("Reserved")
      moderator = PersonItemRole.find_by_name("Moderator")
      invisible = PersonItemRole.find_by_name("Invisible")
      peopleList = nil
      if (params[:backofbadge] != nil)
       peopleList = params[:backofbadge][:person_id]
      end
      excludeNonPublished = false;
      if (params[:excludeNonPublished])
        excludeNonPublished = true;
      end
      maxquery = "select MAX(x) from (select Count(*) as x from programme_item_assignments group by person_id) l;"
      maxList = ActiveRecord::Base.connection.select_rows(maxquery)
      maxItems = maxList[0][0].to_i;
      @people = nil
      selectConditions = '(acceptance_status_id = '+ accepted.id.to_s + ' OR acceptance_status_id = ' + probable.id.to_s + ')'
   
      if (peopleList != nil && peopleList.size() != 0)
            addOr = "AND ("
        peopleList.each do |p|
          selectConditions = selectConditions + addOr + 'people.id ='+ p
          addOr = " OR "
        end
        selectConditions = selectConditions + ")"
      end
      @names = Person.all(:include => [:programmeItems => [:time_slot, :room, :format]], :conditions => selectConditions, :order => "people.last_name,people.first_name, time_slots.start") 

      output = Array.new
      headerList = Array.new
      headerList << "Name"
      headerList << "Number Of Panels"
      1.upto(maxItems) do |number|
        headerValue = "Panel"+number.to_s
        headerList << headerValue
      end
      output.push headerList 

      @names.each do |name|
         panels = Array.new
         items = name.programmeItems;
         items.each do |p|
            next if ((excludeNonPublished == true) and (p.print == false))
            a = ProgrammeItemAssignment.first(:conditions => {:person_id => name.id, :programme_item_id => p.id})
            next if p.time_slot.nil?
            next if ((excludeNonPublished == true) and (a.role_id == invisible.id))
            next if (a.role_id == reserved.id)
            panelstr = "#{p.time_slot.start.strftime('%a %H:%M')} "
            panelstr << ": #{p.room.name} (#{p.room.venue.name})" unless p.room.nil?
            if (p.short_title.nil? == false && p.short_title != '')
             panelstr << " #{p.short_title}"
            else
             panelstr << " #{p.title}"
            end
            if a.role_id == moderator.id
               panelstr << " (M)"
            elsif a.role_id == invisible.id
              panelstr << " (I)"
            end
        
            panels << panelstr
         end
         if (panels.size() != 0)
           personList = Array.new
           personList << name.getFullPublicationName;
           personList << panels.size()
           1.upto(maxItems) do |number|
            if (number <= panels.size())
              personList << panels[number-1];
            else
              personList << "";
            end
           end
           output.push personList 
         end
                           
      end
      outfile = "badge_" + Time.now.strftime("%m-%d-%Y") + ".csv"

      csv_out_noconv(output, outfile)
      
  end
  
  def RoomSign
     moderator = PersonItemRole.find_by_name("Moderator")
     invisible = PersonItemRole.find_by_name("Invisible")
     reserved = PersonItemRole.find_by_name("Reserved")

     roomList = nil
 
     if (params[:roomSign] != nil)
         roomList = params[:roomSign][:room_id]
     end

     if (params[:roomSign] != nil)
         day = params[:roomSign][':day_id'].to_i
     end
     
      #list anything starting after 3am (before is part of the previous day
     startDateTime =  Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + 3.hours;
     
     selectConditions = '(time_slots.start IS NOT NULL) and (programme_items.print = true)'
     hasDate = false;
     currDateTime = startDateTime
     nextDateTime = startDateTime
     if (day != nil)
       hasDate = true
       currDateTime = startDateTime + ((day-1)*24).hours
       currString = currDateTime.utc.strftime('%Y-%m-%d %H:%M')
       nextDateTime = startDateTime + ((day)*24).hours
       nextString = nextDateTime.utc.strftime('%Y-%m-%d %H:%M')
       selectConditions = selectConditions + " AND (time_slots.start >= '" + currString + "' and time_slots.start < '" + nextString + "')"
     end
     
     if (roomList != nil && roomList.size() != 0)
       addOr = 'AND ('
       roomList.each do |r|
         selectConditions = selectConditions + addOr + " rooms.id = " + r.to_s;
         addOr = ' OR '
       end
       selectConditions = selectConditions + ')'
     end
     
     # get max panels per room
     maxquery = "select MAX(x) from (select Count(*) as x from room_item_assignments join time_slots on (room_item_assignments.time_slot_id = time_slots.id) join programme_items on (room_item_assignments.programme_item_id = programme_items.id) join rooms on (room_item_assignments.room_id = rooms.id) "
     if (selectConditions != '')
       maxquery = maxquery + "where " + selectConditions
     end
     maxquery = maxquery + " group by room_id) l;"
     maxList = ActiveRecord::Base.connection.select_rows(maxquery)
     maxItems = maxList[0][0].to_i;
      
     @panels = ProgrammeItem.all(:include => [:people, :time_slot, {:room => :venue}, :format, :equipment_needs,], :conditions => selectConditions, :order => "venues.name,rooms.name,time_slots.start") 
  

    maxPanelInRoom = 0
    panellist = []
    panelinfo = {}
    currRoom = 0
    currDay = ""
    output = []
      headerList = Array.new
      headerList << "Room"
      headerList << "day"
      1.upto(maxItems) do |number|
        numberString = number.to_s
        headerValue = "Time"+numberString
        headerList << headerValue
        headerValue = "Title"+numberString
        headerList << headerValue
        headerValue = "Description"+numberString
        headerList << headerValue
        headerValue = "Participants"+numberString
        headerList << headerValue
      end      
      output.push headerList 
      
    @panels.each do |p|
      if ((currDay != "" && currDay != p.time_slot.start.strftime('%a')) || (currRoom != 0 and currRoom != p.room.id))
          outputlist = []
          outputlist << panellist[0]['roomName']
          outputlist << panellist[0]['day']
          1.upto(maxItems) do |num|
            if (panellist.size() != 0 && num <= panellist.size())
              outputlist << panellist[num-1]['time']
              outputlist << panellist[num-1]['title']
              outputlist << panellist[num-1]['description']
              outputlist << panellist[num-1]['participants']
            else
              outputlist << "";
              outputlist << "";
              outputlist << "";
              outputlist << "";
            end
          end
          output.push outputlist
          panellist = []
      end
      currDay = p.time_slot.start.strftime('%a')
      currRoom = p.room.id
      
      panelinfo['roomName'] = p.room.name
      panelinfo['day'] = p.time_slot.start.strftime('%a')
      panelTime = p.time_slot.start.strftime('%l:%M %p')
      panelinfo['time'] = panelTime
      panelinfo['title'] = p.title
      panelinfo['description'] = p.precis
      partlist = []
      p.programme_item_assignments.each do |part|
         if part.role_id == moderator.id
            partlist.push "#{part.person.getFullPublicationName.strip} (M)"
         elsif part.role_id != reserved.id and part.role_id != invisible.id
            partlist.push part.person.getFullPublicationName.strip
         end
      end
      partstr = partlist.join(", ")
      panelinfo['participants'] = partstr
      panellist << panelinfo
      panelinfo = {}
    end
    
    if (panellist.size() != 0)
          outputlist = []
          outputlist << panellist[0]['roomName']
          outputlist << panellist[0]['day']
          1.upto(maxItems) do |num|
            if (panellist.size() != 0 && num <= panellist.size())
              outputlist << panellist[num-1]['time']
              outputlist << panellist[num-1]['title']
              outputlist << panellist[num-1]['description']
              outputlist << panellist[num-1]['participants']
            else
              outputlist << "";
              outputlist << "";
              outputlist << "";
              outputlist << "";
            end
          end
          output.push outputlist
    end
    
    outfile = "room_" + Time.now.strftime("%m-%d-%Y") + ".csv"

    csv_out_noconv(output, outfile)
  end

end
