#
require "prawn/measurement_extensions"

prawn_document(:page_size => @page_size, :page_layout => @orientation) do |pdf|
    page_height = pdf.bounds.top_right[1]
    page_width = pdf.bounds.top_right[0]

    first_page = true
    @people.each do |p|
        pdf.start_new_page if !first_page
        first_page = false
        pdf.pad(5) { pdf.text '<b>' + p.getFullPublicationName + "</b>", :size => 30, :inline_format => true, :align => :center }
        p.programmeItemAssignments.each do |assignment|
            if assignment.programmeItem.time_slot && (@allowed_roles.include? assignment.role)
                str = '<b>' + assignment.programmeItem.title + "</b>,  "
                str += assignment.programmeItem.time_slot.start.strftime('%A') + ' ' + assignment.programmeItem.time_slot.start.strftime('%H:%M') + "\n"
                str += ' ' + assignment.role.name + "\n"
                str += assignment.programmeItem.format.name + ', ' + assignment.programmeItem.room.name + ' (' + assignment.programmeItem.room.venue.name + ")\n"
            
                pdf.pad(5) { pdf.text str, :inline_format => true }
                pdf.pad_bottom(10) { pdf.text assignment.programmeItem.participant_notes, :inline_format => true }
            end        
        end
    end

end
