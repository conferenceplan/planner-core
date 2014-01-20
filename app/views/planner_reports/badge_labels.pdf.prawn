#
require "prawn/measurement_extensions"

# :page_layout => @orientation
prawn_document(:page_size => @label_dimensions.page_size,
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
        label += p.programmeItems.collect { |i|
        if i.time_slot
           "<b>" + i.time_slot.start.strftime('%a %H:%M') + "</b> : " + i.room.name + " (" + i.room.venue.name + ") " + i.title
        end
        }.compact.join("\n")
    
        y, x = i.divmod(cols)
            pdf.grid(y,x).bounding_box do |b|
                # use text_box so that we truncate/re-size the text
                pdf.text_box label, :at => pdf.bounds.top_left, 
                            :width => pdf.bounds.right, 
                            :height => pdf.bounds.height, 
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
