
# TODO - get the dimensions etc from db. i.e. encode avery label dimensions
cols = 3
rows = 6
gutter = 10
prawn_document() do |pdf|
    pdf.define_grid(:columns => cols, :rows => rows, :gutter => gutter)
    
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
                # use text_box so that we truncate
                pdf.stroke do |h|
                    pdf.line pdf.bounds.top_right, pdf.bounds.bottom_left
                end
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
