#
require "prawn/measurement_extensions"

prawn_document(:page_size => @page_size, :page_layout => @orientation) do |pdf|
    render "font_setup", :pdf => pdf
    
    page_height = pdf.bounds.top_right[1]
    page_width = pdf.bounds.top_right[0]

    first_page = true
    @people.each do |p|
        pdf.start_new_page if !first_page
        first_page = false
        pdf.pad(5) { pdf.text '<b>' + p.getFullPublicationName + "</b>", :size => 30, :inline_format => true, :align => :center }
        p.programmeItemAssignments.
            sort_by{ |a| (a.programmeItem.parent && a.programmeItem.parent.time_slot) ? a.programmeItem.parent.time_slot.start : (a.programmeItem.time_slot ? a.programmeItem.time_slot.start : @conf_start_time) }.
            each do |assignment|
                if (@allowed_roles.include? assignment.role)
                    str = '<b>' + assignment.programmeItem.title + "</b>"

                    if assignment.programmeItem.parent
                        str += ' (<i>' + assignment.programmeItem.parent.title + "</i>),  "
                        str += assignment.programmeItem.parent.time_slot.start.strftime('%A') + ' ' + assignment.programmeItem.parent.time_slot.start.strftime(@plain_time_format) 
                        str += (assignment.programmeItem.parent.room ? ' - ' + assignment.programmeItem.parent.room.name + ' (' + assignment.programmeItem.parent.room.venue.name + ")" : '')
                    else
                        str += ", "
                        str += assignment.programmeItem.time_slot.start.strftime('%A') + ' ' + assignment.programmeItem.time_slot.start.strftime(@plain_time_format) 
                        str += (assignment.programmeItem.room ? ' - ' + assignment.programmeItem.room.name + ' (' + assignment.programmeItem.room.venue.name + ")" : '')
                    end
                    str += "\n"

                    str += (assignment.programmeItem.format ? assignment.programmeItem.format.name + ', ' : '')
                    str += ' ' + assignment.role.name + "\n"
                    
                    # Add co-participants
                    str += '<i>'
                    first_person = true
                    assignment.programmeItem.programme_item_assignments.collect {|a| ([PersonItemRole['Participant'],PersonItemRole['Moderator']].include? a.role) ? a : nil}.compact.each do |p|
                        if !first_person
                            str += ', '
                        end
                        first_person = false
                        str += p.person.getFullPublicationName 
                        str += '(' + p.role.name[0] + ')' if p.role == PersonItemRole['Moderator']
                    end
                    str += '</i>'
    
                    # Add programme notes for participants
                    str += !assignment.programmeItem.participant_notes.blank? ? "\n<b>Notes:</b>\n" + assignment.programmeItem.participant_notes : ''
                    
                    pdf.pad_top(10) { pdf.text str, :inline_format => true }

#                    if assignment.programmeItem.equipment_needs && (assignment.programmeItem.equipment_needs.size > 0)
#                        str = "<i>Equipment:</i> " + assignment.programmeItem.equipment_needs.collect {|e| e.equipment_type.description if e.equipment_type }.compact.join(", ")
#                        pdf.text str, :inline_format => true, :indent_paragraphs => 30
#                    end

    #                pdf.pad_bottom(10) { pdf.text assignment.programmeItem.participant_notes, :inline_format => true }
                end
        end
    end

end
