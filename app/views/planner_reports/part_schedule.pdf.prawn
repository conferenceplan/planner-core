#
require "prawn/measurement_extensions"

def time_part(item)
    item.start_time.strftime('%A') + ' ' + 
    item.start_time.strftime(@plain_time_format) + ' - ' +
    item.end_time.strftime(@plain_time_format)
end

def room_part(room)
    (room ? ', ' + room.name + (@single_venue ? '' : ' (' + room.venue.name + ")") : '')
end

prawn_document(:page_size => @page_size, :page_layout => @orientation) do |pdf|
    render "font_setup", :pdf => pdf
    
    page_height = pdf.bounds.top_right[1]
    page_width = pdf.bounds.top_right[0]

    first_page = true
    @people.each do |p|
        pdf.start_new_page if !first_page
        first_page = false
        pdf.pad(5) { pdf.text '<b>' + p.getFullPublicationName + "</b> - " + (p.company ? p.company : "") , :size => 30, :inline_format => true, :align => :center }
        p.programmeItemAssignments.
            sort_by{ |a| (a.programmeItem.parent && a.programmeItem.parent.time_slot) ? a.programmeItem.parent.time_slot.start : (a.programmeItem.time_slot ? a.programmeItem.time_slot.start : @conf_start_time) }.
            each do |assignment|
                if (@allowed_roles.include? assignment.role)
                    str = "<font size='16'><b>" + assignment.programmeItem.title + "</b></font>"
                    str += ' (<i>part of ' + assignment.programmeItem.parent.title + "</i>)" if assignment.programmeItem.parent
                    str += (assignment.programmeItem.format ? (" <font size='10'>[" + assignment.programmeItem.format.name + "]</font>" ) : '') 

                    str += "\n"
                    str += time_part(assignment.programmeItem) 
                    if assignment.programmeItem.parent
                        str += room_part(assignment.programmeItem.parent.room)
                    else
                        str += room_part(assignment.programmeItem.room)
                    end
                    str += "\n"

                    # Add co-participants
                    # str += '<i>'
                    first_person = true
                    assignment.programmeItem.programme_item_assignments.collect {|a| (@allowed_roles.include? a.role) ? a : nil}.compact.each do |assignment|
                        if !first_person
                            str += ', '
                        end
                        first_person = false
                        str += "<b>" if p == assignment.person
                        str += assignment.person.getFullPublicationName 
                        str += '(' + (assignment.description.blank? ? assignment.role.name : assignment.description) + ')' if assignment.role == PersonItemRole['Moderator']
                        str += "</b>" if p == assignment.person
                        str += ' - <i>' + assignment.person.company + "</i>" if !p.company.blank?
                    end
                    # str += '</i>'
    
                    # Add programme notes for participants
                    str += !assignment.programmeItem.participant_notes.blank? ? "\n<b>Notes:</b>\n" + assignment.programmeItem.participant_notes : ''
                    
                  # pdf.group do |g|
                  pdf.pad_top(10) { pdf.text str, :inline_format => true, :leading => 3 }
                  # end
                end
            end
    end
end
