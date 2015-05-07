#
#
#
require "planner_report_helpers"

class PlannerReportsController < PlannerController
  include PlannerReportHelpers

  before_filter :get_print_options
  def get_print_options
    @site_config = SiteConfig.first
    @plain_time_format = (@site_config.print_time_format == '24') ? '%H:%M' : '%I:%M %p'
    @time_format = (@site_config.print_time_format == '24') ? '%a %H:%M' : '%a %I:%M %p'
    @day_and_time_format = (@site_config.print_time_format == '24') ? '%A %H:%M %y-%m-%d': '%A %I:%M %p %y-%m-%d'
  end
  
  #
  #
  #
  def report_word_counts
    title_size = params[:title_size] ? params[:title_size].to_i : 0
    short_title_size = params[:short_title_size] ? params[:short_title_size].to_i : 0
    precis_size = params[:precis_size] ? params[:precis_size].to_i : 0
    short_precis_size = params[:short_precis_size] ? params[:short_precis_size].to_i : 0
    
    @res = PlannerReportsService.word_counts(title_size, short_title_size, precis_size, short_precis_size)

    respond_to do |format|
      format.json
      format.csv {
        outfile = "report_word_counts_" + Time.now.strftime("%m-%d-%Y") + ".csv"
        output = Array.new
        output.push ['Title','Title Words','Short Title', 'Short Title Words', 'Description', 'Description Words', 'Short Description', 'Short Description Words']
        @res.each do |r|
          output.push [
            r['title'],
            r['title_words'],
            r['short_title'],
            r['short_title_words'],
            r['precis'],
            r['precis_words'],
            r['short_precis'],
            r['short_precis_words'],
          ]
        end
        csv_out(output, outfile)
      }
    end
  end
  
  #
  #
  #
  def participants_with_no_bios
    @people = PlannerReportsService.findParticipantsWithNoBios

    respond_to do |format|
      format.json
      format.csv {
        outfile = "participants_no_bios_" + Time.now.strftime("%m-%d-%Y") + ".csv"
        output = Array.new
        output.push ['Name','Invite Status','Acceptance Status']
        @people.each do |person|
          output.push [
            person.getFullPublicationName,
            person.invitestatus.name,
            person.acceptance_status.name
          ]
        end
        csv_out(output, outfile)
      }
    end
  end
  
  #
  #
  #
  def people_nbr_items
    
    @assignments = PlannerReportsService.findPersonAndItemConstraints
    
    respond_to do |format|
      format.json
      format.csv {
        outfile = "people_nbr_items" + Time.now.strftime("%m-%d-%Y") + ".csv"
        output = Array.new

        output.push [
          'Person','Day','Nbr of Items','Max per Day','Max per Con','Items'
        ]
        
        @assignments.each do |assignment|
          
          output.push [
                assignment.person.getFullPublicationName,
                (Time.zone.parse(SiteConfig.first.start_date.to_s) + assignment.day.day).strftime('%A'),
                assignment.nbr_items,
                (assignment.max_items_per_day ? assignment.max_items_per_day : ''),
                (assignment.max_items_per_con ? assignment.max_items_per_con : ''),
                assignment.person.programmeItemAssignments.collect { |pi|
                        pi.programmeItem.title if pi.programmeItem && pi.programmeItem.room_item_assignment && 
                                                  pi.programmeItem.room_item_assignment.day == assignment.day &&
                                                  ([PersonItemRole['Participant'], PersonItemRole['Moderator']].include? pi.role)
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
  def items_with_one_person
    
    @assignments = PlannerReportsService.findItemsWithOneParticipant
    
    respond_to do |format|
      format.json
      format.csv {
        outfile = "items_with_one_person" + Time.now.strftime("%m-%d-%Y") + ".csv"
        output = Array.new

        output.push [
          'Title','Person','Items for Person'
        ]

        @assignments.each do |assignment|
          output.push [
              assignment.programmeItem ? assignment.programmeItem.title : '',
              assignment.person.getFullPublicationName,
              assignment.person.programmeItemAssignments.collect { |pi|
                pi.programmeItem.title if pi.programmeItem && pi.programmeItem.room_item_assignment && 
                                  ([PersonItemRole['Participant'], PersonItemRole['Moderator']].include? pi.role)
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
  def people_items_over_max
    
    @assignments = PlannerReportsService.findPeopleOverMaxItems
    
    respond_to do |format|
      format.json
      format.csv {
        outfile = "people_items_over_max" + Time.now.strftime("%m-%d-%Y") + ".csv"
        output = Array.new

        output.push [
          'Person','Nbr of Items','Max per Day','Max per Con','Items'
        ]
        
        @assignments.each do |assignment|
          
          output.push [
                assignment.person.getFullPublicationName,
                assignment.nbr_items,
                (assignment.max_items_per_day ? assignment.max_items_per_day : ''),
                (assignment.max_items_per_con ? assignment.max_items_per_con : ''),
                assignment.person.programmeItemAssignments.collect { |pi|
                        pi.programmeItem.title if pi.programmeItem && pi.programmeItem.room_item_assignment && 
                                                  ([PersonItemRole['Participant'], PersonItemRole['Moderator']].include? pi.role)
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
  def capacity_report
    @items = PlannerReportsService.items_over_capacity
    
    respond_to do |format|
      format.json
      format.csv {
        outfile = "items_over_capacity" + Time.now.strftime("%m-%d-%Y") + ".csv"
        output = Array.new

        output.push [
          'Title','Format','Start Time','End Time','Room','Venue','Capacity', 'Estimated Audience'
        ]
        
        @items.each do |item|
          
          output.push [item.title,
            (item.format ? item.format.name : ''), 
            ((item.time_slot != nil) ? item.time_slot.start.strftime('%a %H:%M') : ''),
            ((item.time_slot != nil) ? item.time_slot.end.strftime('%a %H:%M') : ''),
            ((item.room != nil) ? item.room.name : ''),
            ((item.room != nil) ? item.room.venue.name : ''),
            ((item.room != nil) ? item.room.room_setup.capacity : ''),
            item.audience_size
          ]
        end
        
        csv_out(output, outfile)
      }
    end
  end
  
  #
  #
  #
  def equipment_needs
    scheduled = params[:scheduled] == "true"
    format_id = params[:format_id].to_i > 0 ? params[:format_id].to_i : nil
    plus_setups = false
    @panels = PlannerReportsService.findPanelsWithPanelists('','1900-01-01', format_id, scheduled, true, plus_setups)
    
    respond_to do |format|
      format.json
      format.csv {
        outfile = "equipment_needs" + Time.now.strftime("%m-%d-%Y") + ".csv"
        output = Array.new

        output.push [
          'Ref','Title','Min People','Max People','Format','Day', 'Start Time','End Time','Room','Venue','Equipment'
        ]
        
        @panels.each do |panel|
          
          output.push [panel.pub_reference_number, panel.title, panel.minimum_people, 
            panel.maximum_people, 
            (panel.format ? panel.format.name : ''), 
            ((panel.time_slot != nil) ? panel.time_slot.start.strftime('%a') : ''),
            ((panel.time_slot != nil) ? panel.time_slot.start.strftime('%H:%M') : ''),
            ((panel.time_slot != nil) ? panel.time_slot.end.strftime('%H:%M') : ''),
            ((panel.room != nil) ? panel.room.name : ''),
            ((panel.room != nil) ? panel.room.venue.name : ''),
            panel.equipment_needs.collect {|e| e.equipment_type.description if e.equipment_type }.join(","),
          ]
        end
        
        csv_out(output, outfile)
      }
    end

  end
  
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
  def panels_without_moderator
    
    @panels = PlannerReportsService.findPanelsWithoutModerators
     
    respond_to do |format|
      format.json
      format.csv {
        outfile = "panels_without_moderator_" + Time.now.strftime("%m-%d-%Y") + ".csv"
        output = Array.new
        output.push [
          'Ref','Title','Min People','Max People','Format','Area(s)','Start Time','End Time','Room','Venue',
          'Equipment','Participants','Moderators','Reserve','Invisible'
        ]
        
        @panels.each do |panel|
          
          count = panel.programme_item_assignments.length

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
  def people_without_panels
    @people = PlannerReportsService.findPeopleWithoutItems
    
    respond_to do |format|
      format.json
      format.csv {
        outfile = "people_no_items_" + Time.now.strftime("%m-%d-%Y") + ".csv"
        output = Array.new
        output.push ['Name','Invite Status','Acceptance Status']
        @people.each do |person|
          output.push [
            person.getFullPublicationName,
            person.invitestatus.name,
            person.acceptance_status.name
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
    roles = []
    roles << PersonItemRole['Reserved'].id if params[:reserved] == "true"
    roles << PersonItemRole['Invisible'].id if params[:invisible] == "true"
    @people = PlannerReportsService.findPanelistsWithPanels( params[:specific_panelists], 
                            roles, 
                            (params[:scheduled] == "true"), 
                            (params[:forprint] == "true") ).sort_by{ |a| a.pubLastName.mb_chars.normalize(:kd).gsub(/[^-x00-\x7F]/n, '').downcase.to_s }

    respond_to do |format|
      format.json
      format.csv {
        outfile = "panelists_" + Time.now.strftime("%m-%d-%Y") + ".csv"
        output = Array.new
        output.push ['Fisrt Name','Last Name','Status','Items', 'Pub Ref Nbr']
        
        # TODO - want to sort by the last name
        
        @people.each do |person|
          output.push [
            person.pubFirstName,
            person.pubLastName,
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
            }.reject { |c| c == nil }.join("\n"),
            person.programmeItemAssignments.collect { |pi|
                if (pi.programmeItem)
                    (pi.programmeItem.pub_reference_number ? pi.programmeItem.pub_reference_number.to_s + ' ' : '' )
                end
            }.reject { |c| c == nil }.join(",")
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
    @taginfo = PlannerReportsService.findPeopleByTag params[:tags]

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
                    t['pub_first_name'] + ' ' + t['pub_last_name'] + ' ' + (t['pub_suffix'] ? ' ' + t['pub_suffix'] : '')
                else
                    t['first_name'] + ' ' + t['last_name'] + ' ' + (t['suffix'] ? ' ' + t['suffix'] : '')
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
  def participants_report
    @page_size = params[:page_size]
    @orientation = params[:orientation] == 'portrait' ? :portrait : :landscape
    @short_desc = params[:short_desc] ? (params[:short_desc] == 'true') : false # TODO - check if this is needed and if not remove
    @allowed_roles = [PersonItemRole['Participant'],PersonItemRole['Moderator'],PersonItemRole['Speaker']]

    # Get the people and bios
    @people = PlannerReportsService.findPanelistsAndBios

    respond_to do |format|
      format.xml {
        response.headers['Content-Disposition'] = 'attachment; filename="participants_' + Time.now.strftime("%m-%d-%Y") + '.xml"'
      }
      format.pdf {
        response.headers['Content-Disposition'] = 'attachment; filename="participants_' + Time.now.strftime("%m-%d-%Y") + '.pdf"'
      }
      format.xlsx{
        response.headers['Content-Disposition'] = 'attachment; filename="participants_' + Time.now.strftime("%m-%d-%Y") + '.xlsx"'
      }
    end
  end
  
  #
  #
  #
  def program_book_report
    @page_size = params[:page_size]
    @orientation = params[:orientation] == 'portrait' ? :portrait : :landscape
    @short_desc = params[:short_desc] ? (params[:short_desc] == 'true') : false

    TimeSlot.uncached do
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

  end
  
  #
  #
  #
  def table_tents
    peopleList = (params[:people].length > 0) ? URI.unescape(params[:people]).split(',') : nil
    @itemList = (params[:items] && params[:items].length > 0) ? URI.unescape(params[:items]).split(',') : nil
    @single = (!params[:single].blank?) ? params[:single] == "true" : false
    @page_size = params[:page_size]
    @by_time = (@itemList == nil) && (peopleList == nil) && !@single

    if (@itemList == nil) && (peopleList == nil) && !@single
      @items = PublishedProgramItemsService.getPublishedProgramItemsThatHavePeople
    else
      @people = PlannerReportsService.findPublishedPanelistsWithPanels peopleList, nil, @itemList
    end
    
    Person.uncached do
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
  end
  
  #
  #
  #
  def part_schedule
    @page_size = params[:page_size]
    @orientation = params[:orientation] == 'landscape' ? :landscape : :portrait
    peopleList = (params[:people].length > 0) ? URI.unescape(params[:people]).split(',') : nil
    additional_roles = params[:additional_roles] == "true" ? [PersonItemRole['Invisible'].id] : nil
    
    Person.uncached do
      # Only use the scheduled items
      @people = PlannerReportsService.findPanelistsWithPanels peopleList, additional_roles, true, true
      @allowed_roles = [PersonItemRole['Participant'],PersonItemRole['Moderator'],PersonItemRole['Speaker']]
      @allowed_roles.concat([PersonItemRole['Invisible']]) if additional_roles
      
      respond_to do |format|
        format.xml {
          response.headers['Content-Disposition'] = 'attachment; filename="schedules_' + Time.now.strftime("%m-%d-%Y") + '.xml"'
        }
        format.pdf {
          response.headers['Content-Disposition'] = 'attachment; filename="schedules_' + Time.now.strftime("%m-%d-%Y") + '.pdf"'
        }
        format.xlsx{
          response.headers['Content-Disposition'] = 'attachment; filename="schedules_' + Time.now.strftime("%m-%d-%Y") + '.xlsx"'
        }
      end
    end
  end
  
  #
  #
  #
  def badge_labels
    @label_dimensions = LabelDimensions.find(params[:label_type])
    @exclude_items = params[:exclude_items] == "true"
    peopleList = (params[:people].length > 0) ? URI.unescape(params[:people]).split(',') : nil
    additional_roles = params[:additional_roles] == "true" ? [PersonItemRole['Invisible'].id] : nil
    for_print = params[:for_print] ? (params[:for_print] == true) : false
    
    Person.uncached do
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
  end
  
  #
  #
  #
  def room_signs
    @page_size = params[:page_size]
    @day = (params[:day] && (params[:day].to_i > -1)) ? params[:day].to_i : nil
    @orientation = params[:orientation] == 'portrait' ? :portrait : :landscape
    @one_per_page = params[:one_per_page] ? (params[:one_per_page] == "true") : false
    @include_desc = params[:include_desc] ? (params[:include_desc] == "true") : false
    roomList = (params[:rooms].length > 0) ? URI.unescape(params[:rooms]).split(',') : nil
    
    PublishedRoom.uncached do
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
  
  #
  #
  #
  def change_sheet
    @page_size = params[:page_size]
    @orientation = params[:orientation] == 'portrait' ? :portrait : :landscape
    pubIndex = params[:since] ? params[:since].to_i : 0 # id of the publication - need to get previous date
    
    @since_date = PublishedProgramItemsService.determineChangeDate(pubIndex)
    @changes = PublishedProgramItemsService.getUpdates(@since_date)
    @item_changes = PublishedProgramItemsService.getPublishedProgrammeItemsChanges(@since_date)
    
    respond_to do |format|
      format.xml {
        response.headers['Content-Disposition'] = 'attachment; filename="change_sheet_' + Time.now.strftime("%m-%d-%Y") + '.xml"'
      }
      format.pdf {
        response.headers['Content-Disposition'] = 'attachment; filename="change_sheet_' + Time.now.strftime("%m-%d-%Y") + '.pdf"'
      }
      format.xlsx{
        response.headers['Content-Disposition'] = 'attachment; filename="change_sheet_' + Time.now.strftime("%m-%d-%Y") + '.xlsx"'
      }
    end
  end
  

end
