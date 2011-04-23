#
#
#
class PlannerReportsController < PlannerController
  include PlannerReportHelpers
  require 'fastercsv'
  require 'iconv'
  
  def show
  end
  
  def index
  end

  def panels_date_form
  end
 
  def panels_with_panelists

    @outfile = "panels_" + Time.now.strftime("%m-%d-%Y") + ".csv"
 
    if params[:mod_date] == ''
       mod_date = '1900-01-01'
    else 
       mod_date = params[:mod_date]
    end

    panels = ProgrammeItem.all(:include => [:people, :time_slot, :room, :format,], :conditions => ["programme_items.updated_at >= ? or programme_item_assignments.updated_at >= ? or (programme_items.updated_at is NULL and programme_items.created_at >= ?) or (programme_item_assignments.updated_at is NULL and programme_item_assignments.created_at >= ?)", mod_date, mod_date, mod_date, mod_date], :order => "programme_items.id, people.last_name") 

    csv_data = FasterCSV.generate do |csv|
       csv << [
          "Panel",
          "Format",
          "Room",
          "Venue",
          "Time Slot",
          "Participants",
          "Reserved",
       ]
       panels.each do |panel|
         names = Array.new
         rsvd = Array.new
         panel.people.each do |p|
            a = ProgrammeItemAssignment.first(:conditions => {:person_id => p.id, :programme_item_id => panel.id})
            if a.role_id == 16
               names.push "#{p.GetFullName.strip} (M)"
            elsif a.role_id == 18
               rsvd.push p.GetFullName.strip
            else
               names.push p.GetFullName.strip
            end
         end
         part_list = names.join(', ')
         rsvd_list = rsvd.join(', ')
         csv << [
            panel.title,
            panel.format.name,
            (panel.room.nil?) ? '' : panel.room.name,
            (panel.room.nil?) ? '' : Venue.find(panel.room.id).name,
            (panel.time_slot.nil?) ? '' : "#{panel.time_slot.start.strftime('%a %H:%M')} - #{panel.time_slot.end.strftime('%H:%M')}",
            part_list,
            rsvd_list,
         ]
       end
     end

   c = Iconv.new('ISO-8859-15','UTF-8')

   send_data c.iconv(csv_data),
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=#{@outfile}"

   flash[:notice] = "Export complete!"
    
  end

  def panelists_with_panels

    @names = Person.all(:include => :programmeItems, :conditions => {"acceptance_status_id" => "8"}, :order => "people.last_name, programme_items.id") 
    
    @names.each do |name|
       panels = Array.new
       name.programmeItems.find_each(:include => [:time_slot, :room, :format, ]) do |p|
          a = ProgrammeItemAssignment.first(:conditions => {:person_id => name.id, :programme_item_id => p.id})
          panelstr = "#{p.title} (#{p.format.name})"
          if a.role_id == 16
             panelster << " (M)"
          end
          panelstr << ", #{p.time_slot.start.strftime('%a %H:%M')} - #{p.time_slot.end.strftime('%H:%M')}" unless p.time_slot.nil?
          panelstr << ", #{p.room.name} (#{Venue.find(p.room.venue_id).name})" unless p.room.nil?
          if a.role_id == 18
             panelstr = "<i>#{panelstr}</i>"
          end
          if p.time_slot.nil?
             zeroTime = Time.at(0)
             panels.push [zeroTime, "<li>#{panelstr}</li>"]
          else
             panels.push [p.time_slot.start, "<li>#{panelstr}</li>"]
          end
       end
       panels.sort! {|a,b| a[0] <=> b[0]}
       panels.collect! {|a| a[1]}
       name[:details] = "<ul>#{panels.join('')}</ul>"
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
