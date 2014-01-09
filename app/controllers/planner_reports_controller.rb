#
#
#
class PlannerReportsController < PlannerController
  include PlannerReportHelpers

  require 'time_diff'
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
    # @names_only = params[:names_only] ? true : false
    # @names_city_only = params[:names_and_city] ? true : false
      
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
  
  # For prog-ops
   def panels_by_room

      return unless params[:html] || params[:csv] 
   
      cond_str = " time_slots.start is not NULL"
      conditions = Array.new

      # cond_str << " and formats.id in ("
      # conditions.push Format.find_by_name("Panel")
      # cond_str << "?,"
      # conditions.push Format.find_by_name("Reading")
      # cond_str << "?,"
      # conditions.push Format.find_by_name("Publisher Presentation")
      # cond_str << "?,"
      # conditions.push Format.find_by_name("Talk")
      # cond_str << "?,"
      # conditions.push Format.find_by_name("Interview")
      # cond_str << "?,"
      # conditions.push Format.find_by_name("Special Interest Group")
      # cond_str << "?,"
      # conditions.push Format.find_by_name("Workshop")
      # cond_str << "?,"
      # conditions.push Format.find_by_name("Dialog")
      # cond_str << "?,"
      # conditions.push Format.find_by_name("Game Show")
      # cond_str << "?,"
      # conditions.push Format.find_by_name("Book Discussion")
      # cond_str << "?,"
      # conditions.push Format.find_by_name("Auction")
      # cond_str << "?,"
      # conditions.push Format.find_by_name("Demonstration")
      # cond_str << "?)"

      conditions.unshift cond_str

      ord_str = "venues.name desc, rooms.name, time_slots.start, time_slots.end"

      @rooms = Room.all(:include => [:venue, {:programme_items => [:time_slot, :format, :equipment_needs,]}], :conditions => conditions, :order => ord_str) 
      
      output = Array.new
      @rooms.each do |room|
         room.programme_items.each do |panel|

            needs = Array.new
            needs = panel.equipment_needs.all(:include => :equipment_type).map! {|n| n.equipment_type.description} 
            equip = needs.join(', ')
      
            if params[:csv]

               line = [
                       (panel.room.nil?) ? '' : panel.room.name,
                       (panel.room.nil?) ? '' : panel.room.venue.name,
                       (panel.time_slot.nil?) ? '' : panel.time_slot.start.strftime('%a'),
                       (panel.time_slot.nil?) ? '' : "#{panel.time_slot.start.strftime('%H:%M')} - #{panel.time_slot.end.strftime('%H:%M')}",
	               panel.title,
                       equip,
                      ]
   
               output.push line

            else
               panel[:equip] = needs
            end
         end
      end
         
      if params[:csv]
         outfile = "panels_" + Time.now.strftime("%m-%d-%Y") + ".csv"
         headers = [
                    "Room",
                    "Venue",
                    "Day",
                    "Time Slot",
                    "Panel",
                    "Equipment Needs"
                   ]

         output.unshift headers

         csv_out_utf16(output, outfile)
      end
    
   end

  # For prog-ops
   def panels_by_timeslot

      return unless params[:html] || params[:csv] 

      ord_str = "time_slots.start, time_slots.end, venues.name desc, rooms.name"

      @times = TimeSlot.all(:joins => [{:rooms => :venue}, {:programme_items => :format}], 
            :include => [{:rooms => :venue}, {:programme_items => :equipment_needs}], 
            :conditions => "time_slots.start is not NULL", 
            :order => ord_str) 
      
      output = Array.new
      # @grouped_times = Hash.new
      @times.each do |time|
         time.programme_items.each do |panel|
               if params[:csv]
                  needs = Array.new
                  needs = panel.equipment_needs.all(:include => :equipment_type).map! {|n| n.equipment_type.description} 
                  equip = needs.join(', ')
   
                  line = [
                          (panel.time_slot.nil?) ? '' : panel.time_slot.start.strftime('%a'),
                          (panel.time_slot.nil?) ? '' : "#{panel.time_slot.start.strftime('%H:%M')} - #{panel.time_slot.end.strftime('%H:%M')}",
                          (panel.room.nil?) ? '' : panel.room.name,
                          (panel.room.nil?) ? '' : panel.room.venue.name,
	                  panel.title,
                          equip,
                         ]
      
                  output.push line
               end
         end
      end
         
      if params[:csv]
         outfile = "panels_" + Time.now.strftime("%m-%d-%Y") + ".csv"
         headers = [
                    "Day",
                    "Time Slot",
                    "Room",
                    "Venue",
                    "Panel",
                    "Equipment Needs"
                   ]

         output.unshift headers

         csv_out_utf16(output, outfile)
      end
    
   end

  # Publications
   def program_book_report

      outfile = "prog_guide_" + Time.now.strftime("%m-%d-%Y") + ".csv"
      output = Array.new
      output.push ["sessionid",
                   "day",
                   "time", 
                   "duration",
		               "room",
		               "track",
		               "type",
		               "kids category",
		               "title",
		               "description",
		               "participants",
                   "short title",
                   "reference number",
                   "venue",
                  ]
      @panels = ProgrammeItem.all(:include => [:people, :time_slot, :format,{:room => [:venue]}], :conditions => {"print" => true}, :order => "time_slots.start asc, rooms.name asc") 
      reserved = PersonItemRole.find_by_name("Reserved")
      moderator = PersonItemRole.find_by_name("Moderator")
      invisible = PersonItemRole.find_by_name("Invisible")
      
      @panels.each do |panel|
         next if panel.time_slot.nil?
         names = Array.new
         panel.people.each do |p|
            a = ProgrammeItemAssignment.first(:conditions => {:person_id => p.id, :programme_item_id => panel.id})
            if a.role_id == moderator.id
               names.push "#{p.getFullPublicationName.strip} (M)"
            elsif a.role_id != reserved.id and a.role_id != invisible.id
               names.push p.getFullPublicationName.strip
            end
         end
         context = panel.tags_on(:PrimaryArea)
	 part_list = names.join(', ')
         unless (panel.time_slot.nil?)
            if (panel.duration % 60 == 0)
               duration = Time.diff(panel.time_slot.end, panel.time_slot.start, '%H')[:diff]
            elsif (panel.duration < 60)
               duration = Time.diff(panel.time_slot.end, panel.time_slot.start, '%N')[:diff]
            else
               duration = Time.diff(panel.time_slot.end, panel.time_slot.start, '%H %N')[:diff]
            end
         end
         output.push [panel.id,
	              (panel.time_slot.nil?) ? '' : panel.time_slot.start.strftime('%a'),
	              (panel.time_slot.nil?) ? '' : panel.time_slot.start.strftime('%I:%M %p'),
	              (panel.time_slot.nil?) ? '' : duration,
                      (panel.room.nil?) ? '' : panel.room.name,
		      (context.nil?) ? '' : context[0],
                      (panel.format.nil?) ? '' : panel.format.name,
		      '',
	              panel.title,
	              panel.precis,
                      part_list,
                      panel.short_title,
                      panel.pub_reference_number,
                      panel.room.venue.name,
                     ]
      end
      
      csv_out_noconv(output, outfile)

   end

   
   def selectBadgeLabel
      accepted = AcceptanceStatus.find_by_name("Accepted")
      probable = AcceptanceStatus.find_by_name("Probable")
      invitestatus = InviteStatus.find_by_name("Invited")

      @people = Person.all(:include => :programmeItems, :conditions => ['(acceptance_status_id = ? or acceptance_status_id = ?) and invitestatus_id = ?',accepted.id,probable.id,invitestatus.id,], :order => "people.last_name, people.first_name")
      
  end
  def selectScheduleReport
    
      accepted = AcceptanceStatus.find_by_name("Accepted")
      probable = AcceptanceStatus.find_by_name("Probable")
      invitestatus = InviteStatus.find_by_name("Invited")

      @people = Person.all(:include => :programmeItems, :conditions => ['(acceptance_status_id = ? or acceptance_status_id = ?) and invitestatus_id = ?',accepted.id,probable.id,invitestatus.id,], :order => "people.last_name, people.first_name")
      
  end
#
  # This is a sample to do the same as the query report in less time...
  #
  def schedule_report_opt
    @NoShareEmailers = SurveyService.findPeopleWithDoNotShareEmail

    @people = Person.all(
        :conditions => ['((programme_item_assignments.person_id = people.id) AND (programme_item_assignments.role_id in (?)) AND (people.acceptance_status_id in (?)))',
          [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id,PersonItemRole['Invisible'].id],
          [AcceptanceStatus['Accepted'].id, AcceptanceStatus['Probable'].id]],
        :include => [:email_addresses, {:programmeItems => [{:programme_item_assignments => {:person => [:pseudonym, :email_addresses]}}, 
                     :equipment_types, {:room => :venue}, :time_slot]} ],
        :order => "people.last_name asc"
      )  
    
    respond_to do |format|
      format.xml 
    end
  end
  
  def schedule_report_test
    generate_schedule_csv
    respond_to do |format|
      format.xml 
    end
  end


  #
  # This is a sample to do the same as the query report in less time...
  #
  def schedule_report
    peopleList = nil
    categoryList = nil
    if (params[:schedule] != nil)
       peopleList = params[:schedule][:person_id]
       categoryList = params[:schedule][:invitation_category_id]
     end
     
    @NoShareEmailers = SurveyService.findPeopleWithDoNotShareEmail

      selectConditions = ''
      if (peopleList != nil && peopleList.size() != 0)
            addOr = "AND ("
        peopleList.each do |p|
          selectConditions = selectConditions + addOr + 'people.id ='+ p
          addOr = " OR "
        end
        selectConditions = selectConditions + ")"
      end
       if (categoryList != nil && categoryList.size() != 0)
            addOr = "AND ("
        categoryList.each do |p|
          selectConditions = selectConditions + addOr + 'people.invitation_category_id ='+ p
          addOr = " OR "
        end
        selectConditions = selectConditions + ")"
      end
    maxquery = "select MAX(x) from (select Count(*) as x from programme_item_assignments group by person_id) l;"
    maxList = ActiveRecord::Base.connection.select_rows(maxquery)
    maxItems = maxList[0][0].to_i;
    maxPanelInRoom = 0
  
   
    @people = Person.all(
        :conditions => ['((programme_item_assignments.person_id = people.id) AND (programme_item_assignments.role_id in (?)) AND (people.acceptance_status_id in (?)))' + selectConditions,
          [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id,PersonItemRole['Invisible'].id],
          [AcceptanceStatus['Accepted'].id, AcceptanceStatus['Probable'].id]],
        :include => [:email_addresses, {:programmeItems => [{:programme_item_assignments => {:person => [:pseudonym, :email_addresses]}}, 
                     :equipment_types, {:room => :venue}, :time_slot]} ],
        :order => "people.last_name asc, time_slots.start asc"
      )  
    if params[:csv]
      output = Array.new
      output = []
      headerList = Array.new
      headerList << "Name"
      headerList << "email"
      1.upto(maxItems) do |number|
        numberString = number.to_s
        headerValue = "Title"+numberString
        headerList << headerValue
        headerValue = "Room"+numberString
        headerList << headerValue
        headerValue = "Venue"+numberString
        headerList << headerValue
        headerValue = "StrTime"+numberString
        headerList << headerValue
        headerValue = "Description"+numberString
        headerList << headerValue
        headerValue = "Participants"+numberString
        headerList << headerValue
        headerValue = "Equipment"+numberString
        headerList << headerValue
      end      
      output.push headerList 
     
      @people.each do |person|
        panellist = []
        defaultEmail = ''
        if (params[:incl_email])
          person.email_addresses.each do |addr|
             if addr.isdefault
               defaultEmail = addr.email
             end
          end
        end 
        person.programmeItems.each do |itm|
          next if itm.time_slot.nil?
          names = []
          panelinfo = {}
          itm.programme_item_assignments.each do |asg| #.people.each do |part|              
             if asg.role == PersonItemRole['Participant'] || asg.role == PersonItemRole['Moderator']      
               name = asg.person.getFullPublicationName()
               name += " (M)" if asg.role == PersonItemRole['Moderator']  
               if (params[:incl_email])
                   asg.person.email_addresses.each do |addr|
                     if addr.isdefault && (!@NoShareEmailers.index(asg.person))
                       name += "(" + addr.email + ")"
                     end
                   end
               end
               names << name
             end
          end
          equipList = []
          if itm.equipment_types.size == 0
             equipList << "No Equipment Needed"
          end
          itm.equipment_types.each do |equip|
             equipList << equip.description
          end
          panelinfo = {}
          panelinfo['title'] = itm.title
          panelinfo['room'] = itm.room.name
          panelinfo['venue'] = itm.room.venue.name
          panelinfo['time'] = itm.time_slot.start.strftime('%Y-%m-%d %H:%M')
          panelinfo['strtime'] = "#{itm.time_slot.start.strftime('%a %H:%M')} - #{itm.time_slot.end.strftime('%H:%M')}"
          if itm.precis
            description = itm.precis.gsub('\n','')
            description = description.gsub('\r','')
          else
            description = ''  
          end
          panelinfo['description'] = description
          panelinfo['participants'] = names.join(', ')
          panelinfo['equipment'] = equipList.join(', ')                      
          panellist << panelinfo
        
      end
       panellist.sort! {|a,b| a['time'] <=> b['time']}

      outputlist = []
        outputlist << person.getFullPublicationName
        outputlist << defaultEmail
        1.upto(maxItems) do |num|
            if (panellist.size() != 0 && num <= panellist.size())
              outputlist << panellist[num-1]['title']
              outputlist << panellist[num-1]['room']
              outputlist << panellist[num-1]['venue']
              outputlist << panellist[num-1]['strtime']
              outputlist << panellist[num-1]['description']
              outputlist << panellist[num-1]['participants']
              outputlist << panellist[num-1]['equipment']
            else
              outputlist << "";
              outputlist << "";
              outputlist << "";
              outputlist << "";
              outputlist << "";
              outputlist << "";
              outputlist << "";
            end
          end
          output.push outputlist
      end
      outfile = "schedule_" + Time.now.strftime("%m-%d-%Y") + ".csv"

      csv_out_noconv(output, outfile)
    else
      respond_to do |format|
        format.xml 
      end
    end
  end

  # TODO - FIX
  # This is a sample to do the same as the query report in less time...
  # This report is not generating the CSV as expected - needs to be fixed
  #
  def schedule_report_problem
    peopleList = nil
    categoryList = nil

    if (params[:schedule] != nil)
      peopleList = params[:schedule][:person_id]
      categoryList = params[:schedule][:invitation_category_id]
    end

    @NoShareEmailers = SurveyService.findPeopleWithDoNotShareEmail

    selectConditions = ''

    if (peopleList != nil && peopleList.size() != 0)
      addOr = "AND ("
      peopleList.each do |p|
        selectConditions = selectConditions + addOr + 'people.id ='+ p
        addOr = " OR "
      end
      selectConditions = selectConditions + ")"
    end

    if (categoryList != nil && categoryList.size() != 0)
      addOr = "AND ("
      categoryList.each do |p|
        selectConditions = selectConditions + addOr + 'people.invitation_category_id ='+ p
        addOr = " OR "
      end
      selectConditions = selectConditions + ")"
    end

    maxquery = "select MAX(x) from (select Count(*) as x from programme_item_assignments group by person_id) l;"
    maxList = ActiveRecord::Base.connection.select_rows(maxquery)
    maxItems = maxList[0][0].to_i;
    maxPanelInRoom = 0
  
    if params[:csv]
        csv = Array.new
        csv << "Name"
        csv << "email"
        1.upto(maxItems) do |number|
          numberString = number.to_s
          headerValue = "Title"+numberString
          csv << headerValue
          headerValue = "Room"+numberString
          csv << headerValue
          headerValue = "Venue"+numberString
          csv << headerValue
          headerValue = "StrTime"+numberString
          csv << headerValue
          headerValue = "Description"+numberString
          csv << headerValue
          headerValue = "Participants"+numberString
          csv << headerValue
          headerValue = "Equipment"+numberString
          csv << headerValue
  logger.debug "before retrieval loop: #{Time.now}" 
     
        Person.find_each(
          :conditions => ['((programme_item_assignments.person_id = people.id) AND (programme_item_assignments.role_id in (?)) AND (people.acceptance_status_id in (?)))' + selectConditions,
          [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id,PersonItemRole['Invisible'].id],
          [AcceptanceStatus['Accepted'].id, AcceptanceStatus['Probable'].id]],
          :include => [:email_addresses, {:programmeItems => [{:programme_item_assignments => {:person => [:pseudonym, :email_addresses]}}, 
          :equipment_types, {:room => :venue}, :time_slot]} ]
        ) do |person|
          panellist = []
          defaultEmail = ''
          if (params[:incl_email])
            person.email_addresses.each do |addr|
              if addr.isdefault
                defaultEmail = addr.email
              end
            end
          end

          person.programmeItems.each do |itm|
            next if itm.time_slot.nil?
            names = []
            panelinfo = {}

            itm.programme_item_assignments.each do |asg| 
              if asg.role == PersonItemRole['Participant'] || asg.role == PersonItemRole['Moderator']      
                name = asg.person.getFullPublicationName()
                name += " (M)" if asg.role == PersonItemRole['Moderator']  
  
                if (params[:incl_email])
                  asg.person.email_addresses.each do |addr|
                    if addr.isdefault && (!@NoShareEmailers.index(asg.person))
                      name += "(" + addr.email + ")"
                    end
                  end
                end
  
                names << name
              end
            end
  
            equipList = []

            if itm.equipment_types.size == 0
              equipList << "No Equipment Needed"
            end
  
            itm.equipment_types.each do |equip|
              equipList << equip.description
            end
  
            panelinfo = {}
            panelinfo['title'] = itm.title
            panelinfo['room'] = itm.room.name
            panelinfo['venue'] = itm.room.venue.name
            panelinfo['time'] = itm.time_slot.start.strftime('%Y-%m-%d %H:%M')
            panelinfo['strtime'] = "#{itm.time_slot.start.strftime('%a %H:%M')} - #{itm.time_slot.end.strftime('%H:%M')}"
            description = itm.precis.gsub('\n','')
            description = description.gsub('\r','')
            panelinfo['description'] = description
            panelinfo['participants'] = names.join(', ')
            panelinfo['equipment'] = equipList.join(', ')                      
            panellist << panelinfo
               
          end # person.programmeItems.each do |itm|
          panellist.sort! {|a,b| a['time'] <=> b['time']}

          csv << person.getFullPublicationName
          csv << defaultEmail
          1.upto(maxItems) do |num|
            if (panellist.size() != 0 && num <= panellist.size())
              csv << panellist[num-1]['title']
              csv << panellist[num-1]['room']
              csv << panellist[num-1]['venue']
              csv << panellist[num-1]['strtime']
              csv << panellist[num-1]['description']
              csv << panellist[num-1]['participants']
              csv << panellist[num-1]['equipment']
            else
              csv << "";
              csv << "";
              csv << "";
              csv << "";
              csv << "";
              csv << "";
              csv << "";
            end
          end
        end # Person.find_each(
      end #CSV.open(outfile, "w") do |csv|
    logger.debug "after retrieval loop: #{Time.now}" 
      outfile = "schedule_" + Time.now.strftime("%m-%d-%Y") + ".csv"
      csv_out_noconv(csv, outfile)
    else  # if params[:csv]
      @people = Person.all(
        :conditions => ['((programme_item_assignments.person_id = people.id) AND (programme_item_assignments.role_id in (?)) AND (people.acceptance_status_id in (?)))' + selectConditions,
        [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id,PersonItemRole['Invisible'].id],
        [AcceptanceStatus['Accepted'].id, AcceptanceStatus['Probable'].id]],
        :include => [:email_addresses, {:programmeItems => [{:programme_item_assignments => {:person => [:pseudonym, :email_addresses]}}, 
        :equipment_types, {:room => :venue}, :time_slot]} ],
        :order => "people.last_name asc, time_slots.start asc"
      )  

      respond_to do |format|
        format.xml 
      end
    end
  end
  
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

  def selectRoomSign
      @rooms   = Room.find :all
      startDateTime =  Time.zone.parse(SITE_CONFIG[:conference][:start_date]);
      numDays = SITE_CONFIG[:conference][:number_of_days]
      @days = []
      1.upto(numDays) do |day|
        currDate = startDateTime;
        currDate = currDate + ((day-1)*24).hours
        @days << [currDate.strftime('%a'),day];
      end
   
 end
 
   def selectTableTents
    
      accepted = AcceptanceStatus.find_by_name("Accepted")
      probable = AcceptanceStatus.find_by_name("Probable")
      invitestatus = InviteStatus.find_by_name("Invited")

      @people = Person.all(:include => :programmeItems, :conditions => ['(acceptance_status_id = ? or acceptance_status_id = ?) and invitestatus_id = ?',accepted.id,probable.id,invitestatus.id,], :order => "people.last_name, people.first_name")
      @items = ProgrammeItem.all(:include => :programme_item_assignments, :conditions => 'programme_item_assignments.id IS NOT NULL AND print = true',:order => "programme_items.title")
   end

   def tableTents

      accepted = AcceptanceStatus.find_by_name("Accepted")
      probable = AcceptanceStatus.find_by_name("Probable")
      reserved = PersonItemRole.find_by_name("Reserved")
      moderator = PersonItemRole.find_by_name("Moderator")
      invisible = PersonItemRole.find_by_name("Invisible")
      peopleList = nil
      if (params[:tableTents] != nil)
       peopleList = params[:tableTents][:person_id]
     end
     itemList = nil
     if (params[:tableTents] != nil)
       itemList = params[:tableTents][:programme_item_id]
     end
     selectConditions = '(acceptance_status_id = '+ accepted.id.to_s + ' OR acceptance_status_id = ' + probable.id.to_s + ')'

     if (peopleList != nil && peopleList.size() != 0)
       addOr = ' AND ('
       peopleList.each do |p|
         selectConditions = selectConditions + addOr + " people.id = " + p.to_s;
         addOr = ' OR '
       end
       selectConditions = selectConditions + ')'
     end
     
      if (itemList != nil && itemList.size() != 0)
       addOr = ' AND ('
       itemList.each do |i|
         selectConditions = selectConditions + addOr + " programme_item_id = " + i.to_s;
         addOr = ' OR '
       end
       selectConditions = selectConditions + ')'
     end
     
      @names = Person.all(:include => :programmeItems, :conditions => selectConditions, :order => "people.last_name, programme_items.id") 

      output = Array.new
    
      @names.each do |name|
         panels = Array.new
       
         name.programmeItems.find_each(:include => [:time_slot, :room, :format, ],:conditions => 'print = true') do |p|
            next if p.time_slot.nil?
            # skip if we only want certain items
            if (itemList != nil && itemList.size() != 0)
              found = false

              itemList.each do |itm|
                if (p.id == itm.to_i)
                  found = true
                end
              end
              next if found == false
            end
            
            a = ProgrammeItemAssignment.first(:conditions => {:person_id => name.id, :programme_item_id => p.id})
            panelstr = "#{p.title} (#{p.format.name})"
            next if a.role_id == invisible.id || a.role_id == reserved.id                      
            output.push [name.getFullPublicationName,
                            p.title,
                            p.precis,
                            (p.format.nil?) ? '' : p.format.name,
                            (p.room.nil?) ? '' : p.room.name,
                            (p.room.nil?) ? '' : p.room.venue.name,
                            (p.time_slot.nil?) ? '' : "#{p.time_slot.start.strftime('%a')}",
                            (p.time_slot.nil?) ? '' : "#{p.time_slot.start.strftime('%H:%M')}",
                            (p.time_slot.nil?) ? '' : "#{p.time_slot.start.strftime('%Y-%m-%d')}",
                           ]
         end       
      end
         outfile = "table_tents_" + Time.now.strftime("%m-%d-%Y") + ".csv"

         output.unshift ["Name",
                         "Panel Title",
                         "Description",
                         "Format",
                         "Room",
                         "Venue",
                         "Day",
                         "Time",
                         "Date"
                        ]
                        # TODO: need to figure out how to handle utf16. Chnage this report
#to utf16 after publication deadline
#         csv_out_utf16(output, outfile)
          csv_out_noconv(output,outfile)
  end
  
protected

   ###
   def generatePanelistsNamesArray
        output = Array.new
        
        @people.each do |person|
          line = []
          
          line.concat [person.first_name, person.last_name] if @names_city_only
          
          line.concat [person.getFullPublicationName, person.acceptance_status.name]
          
          address = person.getDefaultPostalAddress if @names_city_only
              
          line.concat [
            (person.invitestatus ? person.invitestatus.name : ''),
            (person.invitation_category ? person.invitation_category.name : ''),
            (address ? address.line1 : ''),
            (address ? address.line2 : ''),
            (address ? address.city : ''),
            (address ? address.state : ''),
            (address ? address.postcode : ''),
            (address ? address.country : '')
          ] if @names_city_only

          output << line
        end
        
        titles = ["Name", "Acceptance Status"] if !@names_city_only
          
        titles = ["Fisrt Name", "Last Name","Pseudonym", "Acceptance Status", "Invite Status", "Invite Category", "Line1", "Line2", "City", "State", "Post Code", "Country"] if @names_city_only
        
        output.unshift titles
   end
   
   def generatePanelistsWithPanelsArray
        output = Array.new
        
        @people.each do |person|
          person.programmeItemAssignments.each do |pi|
            if pi.programmeItem
              line = [person.getFullPublicationName, person.acceptance_status.name]
              
              line.concat [  pi.role.name,
                (@displayIds ? (pi.programmeItem.pub_reference_number ? pi.programmeItem.pub_reference_number : 'N/A') : pi.programmeItem.title),
                pi.programmeItem.format.name,
                (pi.programmeItem.room ? pi.programmeItem.room.name : ''),
                (pi.programmeItem.room ? pi.programmeItem.room.venue.name : ''),
                (pi.programmeItem.time_slot ? pi.programmeItem.time_slot.start.strftime('%a %H:%M') + ' - ' + pi.programmeItem.time_slot.end.strftime('%H:%M') : '')
              ] if !@names_only
              
              output << line
            end
          end
        end
        
        titles = ["Name", "Acceptance Status"]
          
        titles .concat [ "Role",
          (@displayIds ? "Ref. Number" : "Panel Title"),
          "Format",
          "Room",
          "Venue",
          "Time"
        ] if !@names_only
        
        output.unshift titles
   end
   
end
