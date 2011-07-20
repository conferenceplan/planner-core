#
#
#
#
class PlannerReportsController < PlannerController
   include PlannerReportHelpers
   include SurveyReportHelpers

   require 'time_diff'
  
   def show
   end
  
   def index
   end

   def panels_date_form
   end
 
   def panels_with_panelists

      if params[:mod_date] == ''
         mod_date = '1900-01-01'
      else 
         mod_date = params[:mod_date]
      end

      if params[:sort_by] == 'time'
         ord_str = "time_slots.start, venues.name desc, rooms.name, people.last_name"
      elsif params[:sort_by] == 'room'
         ord_str = "venues.name desc, rooms.name, time_slots.start, people.last_name"
      else
         ord_str = "programme_items.title, people.last_name"
      end

      cond_str = "(programme_items.updated_at >= ? or programme_item_assignments.updated_at >= ? or (programme_items.updated_at is NULL and programme_items.created_at >= ?) or (programme_item_assignments.updated_at is NULL and programme_item_assignments.created_at >= ?))"

      conditions = [mod_date, mod_date, mod_date, mod_date]

      if params[:sched_only]
            cond_str << " and time_slots.start is not NULL"
      end

      if params[:equip_only]
         if params[:plus_setups]
            setup = Format.find_by_name('RESET')
            cond_str << " and (equipment_needs.programme_item_id is not NULL or formats.id = ?)"
            conditions.push setup
         else
            cond_str << " and equipment_needs.programme_item_id is not NULL"
         end
      end

      if params[:type] && params[:type].to_i > 0
         cond_str << " and formats.id = ?"
         conditions.push params[:type]
      end
      
      conditions.unshift cond_str

      @panels = ProgrammeItem.all(:include => [:people, :time_slot, {:room => :venue}, :format, :equipment_needs,], :conditions => conditions, :order => ord_str) 
      
      reserved = PersonItemRole.find_by_name("Reserved")
      moderator = PersonItemRole.find_by_name("Moderator")
      invisible = PersonItemRole.find_by_name("Invisible")

      min = params[:min].to_i
      max = params[:max].to_i
      output = Array.new
      @panels.each do |panel|
         names = Array.new
         rsvd = Array.new
         panel.people.each do |p|
            a = ProgrammeItemAssignment.first(:conditions => {:person_id => p.id, :programme_item_id => panel.id})
            if a.role_id == moderator.id
               names.push "#{p.GetFullPublicationName.strip} (M)"
            elsif a.role_id == invisible.id
               names.push "#{p.GetFullPublicationName.strip} (I)" if params[:incl_invis]
            elsif a.role_id == reserved.id
               rsvd.push p.GetFullPublicationName.strip if params[:incl_rsvd]
            else
               names.push p.GetFullPublicationName.strip
            end
         end

         needs = Array.new
         needs = panel.equipment_needs.all(:include => :equipment_type).map! {|n| n.equipment_type.description} 
         equip = needs.join(', ')
      
         context = panel.tags_on(:PrimaryArea)
         if params[:csv]

            next if (min > 0 && names.count > min)
            next if (max > 0 && names.count < max)
               
            part_list = names.join(', ')
            rsvd_list = rsvd.join(', ')
           
            line = [panel.title,
		    (context.nil?) ? '' : context[0],
                    (panel.format.nil?) ? '' : panel.format.name,
                    (panel.room.nil?) ? '' : panel.room.name,
                    (panel.room.nil?) ? '' : panel.room.venue.name,
	            (panel.time_slot.nil?) ? '' : panel.time_slot.start.strftime('%a'),
                    (panel.time_slot.nil?) ? '' : "#{panel.time_slot.start.strftime('%H:%M')} - #{panel.time_slot.end.strftime('%H:%M')}",
                   ]
            line.push panel.precis if (!panel.precis.nil? && params[:incl_desc])
            line.push equip, part_list

            line.push rsvd_list if params[:incl_rsvd]

            output.push line

         else
            panel[:context] = context[0]
            panel[:names] = names
            panel[:rsvd] = rsvd
            panel[:equip] = needs
         end
      end
         
      if params[:csv]
         outfile = "panels_" + Time.now.strftime("%m-%d-%Y") + ".csv"
         headers = ["Panel",
                    "Track",
                    "Format",
                    "Room",
                    "Venue",
                    "Day",
                    "Time Slot",
                   ]

       
         headers.push "Description" if params[:incl_desc]
         headers.push "Equipment Needs", "Participants"

         headers.push "Reserved" if params[:incl_rsvd]
 
         output.unshift headers

         csv_out_utf16(output, outfile)
      else
      # we filtered them out of the CSV while building it, but I don't see a clean way to do it for the HTML except at the end
         if min > 0
            @panels.delete_if {|p| p.names.count > min}
         end
         if max > 0
            @panels.delete_if {|p| p.names.count < max}
         end
      end
    
   end
 
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
      @panels = ProgrammeItem.all(:include => [:people, :time_slot, :format,{:room => [:venue]}], :conditions => {"print" => true}, :order => "programme_items.pub_reference_number,people.last_name") 
      reserved = PersonItemRole.find_by_name("Reserved")
      moderator = PersonItemRole.find_by_name("Moderator")
      invisible = PersonItemRole.find_by_name("Invisible")
      
      @panels.each do |panel|
         next if panel.time_slot.nil?
         names = Array.new
         panel.people.each do |p|
            a = ProgrammeItemAssignment.first(:conditions => {:person_id => p.id, :programme_item_id => panel.id})
            if a.role_id == moderator.id
               names.push "#{p.GetFullPublicationName.strip} (M)"
            elsif a.role_id != reserved.id and a.role_id != invisible.id
               names.push p.GetFullPublicationName.strip
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

   def panelists_with_panels
      accepted = AcceptanceStatus.find_by_name("Accepted")
      probable = AcceptanceStatus.find_by_name("Probable")
      reserved = PersonItemRole.find_by_name("Reserved")
      moderator = PersonItemRole.find_by_name("Moderator")
      invisible = PersonItemRole.find_by_name("Invisible")

      @names = Person.all(:include => :programmeItems, :conditions => ['acceptance_status_id = ? or acceptance_status_id = ?',accepted.id,probable.id], :order => "people.last_name, programme_items.id") 

      output = Array.new
    
      @names.each do |name|
         panels = Array.new
         name.programmeItems.find_each(:include => [:time_slot, :room, :format, ]) do |p|
            a = ProgrammeItemAssignment.first(:conditions => {:person_id => name.id, :programme_item_id => p.id})
            panelstr = "#{p.title} (#{p.format.name})"
            if a.role_id == moderator.id
               panelstr << " (M)"
            elsif a.role_id == invisible.id
              panelstr << " (I)"
            end
            panelstr << ", #{p.time_slot.start.strftime('%a %H:%M')} - #{p.time_slot.end.strftime('%H:%M')}" unless p.time_slot.nil?
            panelstr << ", #{p.room.name} (#{p.room.venue.name})" unless p.room.nil?
            if a.role_id == reserved.id
               if params[:incl_rsvd]
                  panelstr = "<i>#{panelstr}</i>"
               else
                  next
               end
            end
            if p.time_slot.nil?
               zeroTime = Time.at(0)
               panels.push [zeroTime, panelstr]
            else
               panels.push [p.time_slot.start, panelstr]
            end
            if params[:csv]
               output.push [name.GetFullPublicationName,
                            (name.acceptance_status_id == accepted.id) ? 'Accepted':'Probable',
                            (a.role_id == reserved.id) ? 'R' : (a.role_id == moderator.id) ? 'M' : (a.role_id == invisible.id) ? 'I' : '',
                            p.title,
                            (p.format.nil?) ? '' : p.format.name,
                            (p.room.nil?) ? '' : p.room.name,
                            (p.room.nil?) ? '' : p.room.venue.name,
                            (p.time_slot.nil?) ? '' : "#{p.time_slot.start.strftime('%a %H:%M')} - #{p.time_slot.end.strftime('%H:%M')}",
                           ]
            end
         end
         panels.sort! {|a,b| a[0] <=> b[0]}
         panels.collect! {|a| a[1]}
         name[:items] = panels
      end
      if params[:csv]
         outfile = "panelists_" + Time.now.strftime("%m-%d-%Y") + ".csv"

         output.unshift ["Name",
                         "Acceptance Status",
                         "Role",
                         "Panel Title",
                         "Format",
                         "Room",
                         "Venue",
                         "Time"
                        ]
         csv_out_utf16(output, outfile)
      end
  end
  
  def schedule_report
      accepted = AcceptanceStatus.find_by_name("Accepted")
      probable = AcceptanceStatus.find_by_name("Probable")
      reserved = PersonItemRole.find_by_name("Reserved")
      moderator = PersonItemRole.find_by_name("Moderator")
      invisible = PersonItemRole.find_by_name("Invisible")

      invitestatus = InviteStatus.find_by_name("Invited")
      @names = Person.all(:include => :programmeItems, :conditions => ['(acceptance_status_id = ? or acceptance_status_id = ?) and invitestatus_id = ? ',accepted.id,probable.id,invitestatus.id], :order => "people.last_name, programme_items.id") 

      output = Array.new
    
      @names.each do |name|
         panels = Array.new
         name.programmeItems.find_each(:include => [:time_slot, :room, :format, :equipment_needs ]) do |p|
            allParticipants = ProgrammeItemAssignment.all(:conditions => {:programme_item_id => p.id})
             if p.time_slot.nil?
              next
            end
            panelstr = "#{p.time_slot.start.strftime('%a %H:%M')} - #{p.time_slot.end.strftime('%H:%M')}"
            panelstr << ", #{p.title} (#{p.format.name})"
            panelstr << ", #{p.room.name} (#{p.room.venue.name})"

            partList = []
            skipreserved = false;
            allParticipants.each do |a|             
               if a.role_id == reserved.id
                 if (a.person_id == name.id)
                   skipreserved = true
                   break
                 end
                 next
               end
               if (a.role_id == invisible.id)
                 next
               end
               partName =  a.person.GetFullPublicationName
              
               surveyList = a.person.GetSurveyQuestionResponse('g93q7')
               
               if a.role_id == moderator.id
                 partName = partName + "(M)"
               end
               
               if (a.role_id != invisible.id)
               if (a.person.GetShareEmail() == true)
                 defaultEmail = a.person.getDefaultEmail
                 if (defaultEmail != nil)
                   partName = partName + "(" + defaultEmail.email + ")"
                 end
               end
               end
               
               partList.push partName
            end
            if (skipreserved == false)
              partstr = partList.join(', ')
              equiplist = []
              if (p.equipment_needs && p.equipment_needs.size != 0)
                p.equipment_needs.each do |equip|
                  equiplist << equip.equipment_type.description
                end
              else
                 equiplist << "None"
              end
              equipstr = equiplist.join(', ')
              equipstr = "Required Equipment: "+ equipstr
              panels.push [p.time_slot.start, panelstr, p.precis, partstr,equipstr]
            end                      
         end
         if (panels.size != 0)
           panels.sort! {|a,b| a[0] <=> b[0]}
           name[:items] = panels
         end
      end
      respond_to do |format|
         format.xml 
      end
   end

   def admin_tags_by_context
      if params[:tag_context]
         context = params[:tag_context]
         tags = ActsAsTaggableOn::Tagging.all(:conditions => ['context = ?', context], :joins => ["join tags on taggings.tag_id = tags.id"], :select => 'distinct(name)')
         tags.collect! {|t| t.name}
         @names = Array.new
         tags.each do |tag|
            @names.concat Person.tagged_with(tag, :on => context)
         end
         @names.uniq!
         @names.sort! {|x,y| x.last_name <=> y.last_name}
         @names.each do |n|
            n[:details] = n.tag_list_on(context)
         end
      end
   end
end
