#
class PlannerReportsService
  
  def self.findPanelsWithPanelists


    @panels = ProgrammeItem.all :include => [:people, :time_slot, {:room => :venue}, :format, :equipment_needs,],
                                :conditions => conditions, 
                                :order => ord_str 

    
    if params[:sort_by] == 'time'
         ord_str = "time_slots.start ASC, time_slots.end ACS, venues.name desc, rooms.name ASC, people.last_name"
      elsif params[:sort_by] == 'room'
         ord_str = "venues.name desc, rooms.name asc, time_slots.start asc, time_slots.end asc, people.last_name"
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
         panel.people.sort {|x,y| x.pubLastName.downcase <=> y.pubLastName.downcase}.each do |p|
         # panel.people.each do |p|
            a = ProgrammeItemAssignment.first(:conditions => {:person_id => p.id, :programme_item_id => panel.id})
            if a.role_id == moderator.id
               names.push "#{p.getFullPublicationName.strip} (M)"
            elsif a.role_id == invisible.id
               names.push "#{p.getFullPublicationName.strip} (I)" if params[:incl_invis]
            elsif a.role_id == reserved.id
               rsvd.push p.getFullPublicationName.strip if params[:incl_rsvd]
            else
               names.push p.getFullPublicationName.strip
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

  end
  
end
