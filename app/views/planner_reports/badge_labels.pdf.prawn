#
require "prawn/measurement_extensions"

bleed = 0.1
prawn_document(:page_size => @label_dimensions.page_size,
                :page_layout => (@label_dimensions.orientation == 'portrait' ? :portrait : :landscape),
                :top_margin => @label_dimensions.top_margin * 1.send(@label_dimensions.unit),
                :bottom_margin => @label_dimensions.bottom_margin * 1.send(@label_dimensions.unit),
                :left_margin => @label_dimensions.left_margin * 1.send(@label_dimensions.unit),
                :right_margin => @label_dimensions.right_margin * 1.send(@label_dimensions.unit),
    ) do |pdf|
    cols = @label_dimensions.across
    rows = @label_dimensions.down

    pdf.define_grid(:columns => cols, :rows => rows, 
                    :row_gutter => (@label_dimensions.vertical_spacing * 1.send(@label_dimensions.unit)), :column_gutter => (@label_dimensions.horizontal_spacing * 1.send(@label_dimensions.unit)))
    
    i = x = y = 0
    @people.each do |p|
    
        label = "<b><u>" + p.getFullPublicationName + "</u></b>\n"
        
        label += p.programmeItemAssignments.collect { |i|
            if i.programmeItem.time_slot && (@allowed_roles.include? i.role)
                "(" + i.role.name[0] +
                ") <b>" + i.programmeItem.time_slot.start.strftime('%a %H:%M') + "</b> : " + 
                i.programmeItem.room.name + 
                (i.programmeItem.short_title.blank? ? i.programmeItem.title : i.programmeItem.short_title)
            end
        }.compact.join("\n")
    
        y, x = i.divmod(cols)
        pdf.grid(y,x).bounding_box do |b|
            # use text_box so that we truncate/re-size the text
            pdf.text_box label, :at => [(pdf.bounds.top_left[0] + bleed.in),(pdf.bounds.top_left[1] + bleed.in)], # plus blead
                            :width => pdf.bounds.right - bleed.in, # minus blead
                            :height => pdf.bounds.height - bleed.in, # minus blead
                            :overflow => :shrink_to_fit,
                            :inline_format => true
        end
        if (y == (rows -1) && x == (cols -1))
            i = 0
            pdf.start_new_page
        else    
            i += 1
        end
    end
end
