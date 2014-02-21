#
#
#
class PlannerReportsController < PlannerController
  include PlannerReportHelpers
  
  #
  #
  #
  def edited_bios
    @editedBios = PlannerReportsService.findEditedBios
    
    respond_to do |format|
      format.json
      format.csv {
        outfile = "panels_" + Time.now.strftime("%m-%d-%Y") + ".csv"
        output = Array.new
        output.push [
          'Name','Bio','Web Site','Twitter','Other Social Media','Photo URL','Facebook'
        ]
        
        @editedBios.each do |e|
          output.push [e.person.getFullPublicationName,
              e.bio,
              e.website ? e.website : '',
              e.twitterinfo ? e.twitterinfo : '',
              e.othersocialmedia ? e.othersocialmedia : '',
              e.photourl ? e.photourl : '',
              e.facebook ? e.facebook : ''
          ]
        end
        
        csv_out(output, outfile)
      }
    end
  end

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
                    ( pi.programmeItem.format ? ' (' + pi.programmeItem.format.name + ') ' : '' ) +
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
    @page_size = params[:page_size]
    @orientation = params[:orientation] == 'portrait' ? :portrait : :landscape
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
    @itemList = (params[:items] && params[:items].length > 0) ? URI.unescape(params[:items]).split(',') : nil
    
    @people = PlannerReportsService.findPublishedPanelistsWithPanels peopleList, nil, @itemList
    @page_size = params[:page_size]
    
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
    @label_dimensions = LabelDimensions.find(params[:label_type])
    peopleList = (params[:people].length > 0) ? URI.unescape(params[:people]).split(',') : nil
    additional_roles = params[:additional_roles] == "true" ? [PersonItemRole['Invisible'].id] : nil
    for_print = params[:for_print] ? (params[:for_print] == true) : false
    
    # Only use the scheduled items
    @people = PlannerReportsService.findPanelistsWithPanels peopleList, additional_roles, true, for_print
    @allowed_roles = [PersonItemRole['Participant'],PersonItemRole['Moderator'],PersonItemRole['Speaker']]
    @allowed_roles.concat([PersonItemRole['Invisible']]) if additional_roles
    
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
  
  #
  #
  #
  def room_signs
    @page_size = params[:page_size]
    @day = (params[:day] && (params[:day].to_i > -1)) ? params[:day].to_i : nil
    @orientation = params[:orientation] == 'portrait' ? :portrait : :landscape
    roomList = (params[:rooms].length > 0) ? URI.unescape(params[:rooms]).split(',') : nil
    
    # Get the program items for the rooms for each day....
    @rooms = PlannerReportsService.findPublishedPanelsByRoom roomList, @day
    
    respond_to do |format|
      format.xml {
        response.headers['Content-Disposition'] = 'attachment; filename="room_signs_' + Time.now.strftime("%m-%d-%Y") + '.xml"'
      }
      format.pdf {
        response.headers['Content-Disposition'] = 'attachment; filename="room_signs_' + Time.now.strftime("%m-%d-%Y") + '.pdf"'
      }
      format.xlsx{
        response.headers['Content-Disposition'] = 'attachment; filename="room_signs_' + Time.now.strftime("%m-%d-%Y") + '.xlsx"'
      }
    end
  end

end
