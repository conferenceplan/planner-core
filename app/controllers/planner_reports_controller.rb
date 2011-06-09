#
#
#
#
class PlannerReportsController < PlannerController
   include PlannerReportHelpers
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
         ord_str = "time_slots.start, rooms.name, people.last_name"
      elsif params[:sort_by] == 'room'
         ord_str = "rooms.name, time_slots.start, people.last_name"
      else
         ord_str = "programme_items.title, people.last_name"
      end

      if params[:sched_only]
         @panels = ProgrammeItem.all(:include => [:people, :time_slot, :room, :format,], :conditions => ["time_slots.start is not NULL and (programme_items.updated_at >= ? or programme_item_assignments.updated_at >= ? or (programme_items.updated_at is NULL and programme_items.created_at >= ?) or (programme_item_assignments.updated_at is NULL and programme_item_assignments.created_at >= ?))", mod_date, mod_date, mod_date, mod_date], :order => ord_str) 
      else
         @panels = ProgrammeItem.all(:include => [:people, :time_slot, :room, :format,], :conditions => ["programme_items.updated_at >= ? or programme_item_assignments.updated_at >= ? or (programme_items.updated_at is NULL and programme_items.created_at >= ?) or (programme_item_assignments.updated_at is NULL and programme_item_assignments.created_at >= ?)", mod_date, mod_date, mod_date, mod_date], :order => ord_str) 
      end

      output = Array.new
      @panels.each do |panel|
         names = Array.new
         rsvd = Array.new
         panel.people.each do |p|
            a = ProgrammeItemAssignment.first(:conditions => {:person_id => p.id, :programme_item_id => panel.id})
            if a.role_id == 16
               names.push "#{p.GetFullPublicationName.strip} (M)"
            elsif a.role_id == 18 
               rsvd.push p.GetFullPublicationName.strip if params[:incl_rsvd]
            else
               names.push p.GetFullPublicationName.strip
            end
         end
         context = panel.tags_on(:PrimaryArea)
         if params[:csv]
            part_list = names.join(', ')
            rsvd_list = rsvd.join(', ')
            output.push [panel.title,
		         (context.nil?) ? '' : context[0],
                         (panel.format.nil?) ? '' : panel.format.name,
                         (panel.room.nil?) ? '' : panel.room.name,
                         (panel.room.nil?) ? '' : panel.room.venue.name,
	                 (panel.time_slot.nil?) ? '' : panel.time_slot.start.strftime('%a'),
                         (panel.time_slot.nil?) ? '' : "#{panel.time_slot.start.strftime('%H:%M')} - #{panel.time_slot.end.strftime('%H:%M')}",
                         part_list,
                         rsvd_list,
                        ]
         else
            panel[:context] = context[0]
            panel[:names] = names
            panel[:rsvd] = rsvd
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
                    "Participants",
                   ]

         headers.push "Reserved" if params[:incl_rsvd]
 
         output.unshift headers

         csv_out(output, outfile)
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
                  ]
      @panels = ProgrammeItem.all(:include => [:people, :time_slot, :room, :format, ], :conditions => {"print" => true}, :order => "time_slots.start, people.last_name") 

      @panels.each do |panel|
         next if panel.time_slot.nil?
         names = Array.new
         panel.people.each do |p|
            a = ProgrammeItemAssignment.first(:conditions => {:person_id => p.id, :programme_item_id => panel.id})
            if a.role_id == 16
               names.push "#{p.GetFullPublicationName.strip} (M)"
            elsif a.role_id != 18 
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
                     ]
      end
      
      csv_out(output, outfile)

   end

   def panelists_with_panels
      accepted = AcceptanceStatus.find_by_name("Accepted")
      probable = AcceptanceStatus.find_by_name("Probable")
      reserved = PersonItemRole.find_by_name("Reserved")
      moderator = PersonItemRole.find_by_name("Moderator")
      @names = Person.all(:include => :programmeItems, :conditions => ['acceptance_status_id = ? or acceptance_status_id = ?',accepted.id,probable.id], :order => "people.last_name, programme_items.id") 

      output = Array.new
    
      @names.each do |name|
         panels = Array.new
         name.programmeItems.find_each(:include => [:time_slot, :room, :format, ]) do |p|
            a = ProgrammeItemAssignment.first(:conditions => {:person_id => name.id, :programme_item_id => p.id})
            panelstr = "#{p.title} (#{p.format.name})"
            if a.role_id == moderator.id
               panelstr << " (M)"
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
                            (a.role_id == reserved.id) ? 'R' : (a.role_id == moderator.id) ? 'M' : '',
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
         csv_out(output, outfile)
      end
  end
  
  def schedule_report
      accepted = AcceptanceStatus.find_by_name("Accepted")
      probable = AcceptanceStatus.find_by_name("Probable")
      reserved = PersonItemRole.find_by_name("Reserved")
      moderator = PersonItemRole.find_by_name("Moderator")
      invitestatus = InviteStatus.find_by_name("Invited")

      @names = Person.all(:include => :programmeItems, :conditions => ['(acceptance_status_id = ? or acceptance_status_id = ?) and invitestatus_id = ? ',accepted.id,probable.id,invitestatus.id], :order => "people.last_name, programme_items.id") 

      output = Array.new
    
      @names.each do |name|
         panels = Array.new
         name.programmeItems.find_each(:include => [:time_slot, :room, :format, ]) do |p|
            allParticipants = ProgrammeItemAssignment.all(:conditions => {:programme_item_id => p.id})
             if p.time_slot.nil?
              next
            end
            panelstr = "#{p.time_slot.start.strftime('%a %H:%M')} - #{p.time_slot.end.strftime('%H:%M')}"
            panelstr << ", #{p.title} (#{p.format.name})"
            
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
               partName =  a.person.GetFullPublicationName
             
               if a.role_id == moderator.id
                 partName = partName + "(M)"
               end
               partList.push partName
            end
            if (skipreserved == false)
              partstr = partList.join(', ')
              panels.push [p.time_slot.start, panelstr, p.precis, partstr]
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
