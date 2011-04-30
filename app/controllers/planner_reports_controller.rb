#
#
#
class PlannerReportsController < PlannerController
   include PlannerReportHelpers
  
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

      @panels = ProgrammeItem.all(:include => [:people, :time_slot, :room, :format,], :conditions => ["programme_items.updated_at >= ? or programme_item_assignments.updated_at >= ? or (programme_items.updated_at is NULL and programme_items.created_at >= ?) or (programme_item_assignments.updated_at is NULL and programme_item_assignments.created_at >= ?)", mod_date, mod_date, mod_date, mod_date], :order => ord_str) 

      output = Array.new
      @panels.each do |panel|
         names = Array.new
         rsvd = Array.new
         panel.people.each do |p|
            a = ProgrammeItemAssignment.first(:conditions => {:person_id => p.id, :programme_item_id => panel.id})
            if a.role_id == 16
               names.push "#{p.GetFullName.strip} (M)"
            elsif a.role_id == 18 
               rsvd.push p.GetFullName.strip if params[:incl_rsvd]
            else
               names.push p.GetFullName.strip
            end
         end
         if params[:csv]
            part_list = names.join(', ')
            rsvd_list = rsvd.join(', ')
            output.push [panel.title,
                         (panel.format == nil) ? '' : panel.format.name,
                         (panel.room == nil) ? '' : panel.room.name,
                         (panel.room == nil) ? '' : panel.room.venue.name,
                         (panel.time_slot == nil) ? '' : "#{panel.time_slot.start.strftime('%a %H:%M')} - #{panel.time_slot.end.strftime('%H:%M')}",
                         part_list,
                         rsvd_list,
                        ]
         else
            panel[:names] = names
            panel[:rsvd] = rsvd
         end
      end
         
      if params[:csv]
         outfile = "panels_" + Time.now.strftime("%m-%d-%Y") + ".csv"
 
         output.unshift ["Panel",
                         "Format",
                         "Room",
                         "Venue",
                         "Time Slot",
                         "Participants",
                         "Reserved",
                        ]

         csv_out(output, outfile)
      end
    
   end

   def panelists_with_panels

      @names = Person.all(:include => :programmeItems, :conditions => {"acceptance_status_id" => "8"}, :order => "people.last_name, programme_items.id") 

      output = Array.new
    
      @names.each do |name|
         panels = Array.new
         name.programmeItems.find_each(:include => [:time_slot, :room, :format, ]) do |p|
            a = ProgrammeItemAssignment.first(:conditions => {:person_id => name.id, :programme_item_id => p.id})
            panelstr = "#{p.title} (#{p.format.name})"
            if a.role_id == 16
               panelstr << " (M)"
            end
            panelstr << ", #{p.time_slot.start.strftime('%a %H:%M')} - #{p.time_slot.end.strftime('%H:%M')}" unless p.time_slot.nil?
            panelstr << ", #{p.room.name} (#{p.room.venue.name})" unless p.room.nil?
            if a.role_id == 18
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
               output.push [name.GetFullName,
                            (a.role_id == 18) ? 'R' : (a.role_id == 16) ? 'M' : '',
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
