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
    render "font_setup", :pdf => pdf
    
    cols = @label_dimensions.across
    rows = @label_dimensions.down
    max_per_label = 6

    pdf.define_grid(:columns => cols, :rows => rows, 
                    :row_gutter => (@label_dimensions.vertical_spacing * 1.send(@label_dimensions.unit)), 
                    :column_gutter => (@label_dimensions.horizontal_spacing * 1.send(@label_dimensions.unit)))
    
    i = x = y = 0
    @people.each do |p|
        labels = []
        labels[0] = "<b>" + p.getFullPublicationName + "</b>\n" if @exclude_items
        
        if (@exclude_items == false)

            items_to_print = p.programmeItemAssignments.
               sort_by{ |a| (a.programmeItem.parent && a.programmeItem.parent.time_slot) ? a.programmeItem.parent.time_slot.start : (a.programmeItem.time_slot ? a.programmeItem.time_slot.start : @conf_start_time) }.
               collect { |i|
                #if i.programmeItem.time_slot && (@allowed_roles.include? i.role)
                if (@allowed_roles.include? i.role)
                    i
                end
            }.compact
            
            nbr_labels = (items_to_print.size / max_per_label) + ((items_to_print.size % max_per_label > 0) ? 1 : 0) - 1
            
            (0..nbr_labels).each do |l|
                labels[l] = "<b><u>" + p.getFullPublicationName + "</u></b>\n" if !@exclude_items
                
                ((l*max_per_label)..(l*max_per_label+max_per_label-1)).each do |p|
                    if items_to_print[p]
                        labels[l] += "(" + items_to_print[p].role.name[0] + ")" 
                        if items_to_print[p].programmeItem.time_slot
                            labels[l] += " <b>" + items_to_print[p].programmeItem.time_slot.start.strftime(@time_format) + "</b>"
                        else
                            labels[l] += " <b>" + items_to_print[p].programmeItem.parent.time_slot.start.strftime(@time_format) + "</b>"
                        end
                        labels[l] +=  " : " 
                        if items_to_print[p].programmeItem.time_slot
                            labels[l] += items_to_print[p].programmeItem.room.name + " "
                        else
                            labels[l] += items_to_print[p].programmeItem.parent.room.name + " "
                        end
                        labels[l] += (items_to_print[p].programmeItem.short_title.blank? ? items_to_print[p].programmeItem.title : items_to_print[p].programmeItem.short_title) + "\n"
                    end
                end
            end
        
        end
    
        labels.each do |label|
            y, x = i.divmod(cols)
            pdf.grid(y,x).bounding_box do |b|
                pdf.transparent(0.5) { pdf.dash(1); pdf.stroke_bounds; pdf.undash }
                # use text_box so that we truncate/re-size the text
                pdf.text_box label, :at => [(pdf.bounds.top_left[0] + bleed.in),(pdf.bounds.top_left[1] - bleed.in)], # plus blead
                                :width => pdf.bounds.right - bleed.in, # minus blead
                                :height => pdf.bounds.height - bleed.in, # minus blead
                                :overflow => :shrink_to_fit,
                                :inline_format => true,
                                :fallback_fonts => fallback_fonts
            end
            if (y == (rows -1) && x == (cols -1))
                i = 0
                pdf.start_new_page
            else    
                i += 1
            end
        end
    end
end
