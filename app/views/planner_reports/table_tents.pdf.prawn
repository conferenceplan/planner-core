require "prawn/measurement_extensions"

def print_assignment(pdf, item, assignment, page_width, page_height)
    person = assignment.person
        
    pdf.rotate 180, :origin => [page_width/2, pdf.cursor - page_height/8] do
            pdf.font_size 80 do
                pdf.text_box person.getFullPublicationName, 
                        :at => [10, pdf.cursor],
                        :width => page_width,
                        :height => 100.pt,
                        :overflow => :shrink_to_fit,
                        :mi_font_size => 30,
                        :fallback_fonts => planner_fallback_fonts
            end
    end
    
    #
    if !@single
        pdf.move_down (page_height/2 + 40.pt)
        pdf.text item.title, :inline_format => true, :fallback_fonts => planner_fallback_fonts
        pdf.text "<b>Part of:</b> " + item.parent.title, :inline_format => true, :fallback_fonts => planner_fallback_fonts if item.parent
        pdf.text item.format.name, :fallback_fonts => planner_fallback_fonts if item.format
        if item.published_room
            pdf.text item.published_room.name + ' ' + item.published_room.published_venue.name, :fallback_fonts => planner_fallback_fonts
        elsif item.parent
            pdf.text item.parent.published_room.name + ' ' + item.parent.published_room.published_venue.name, :fallback_fonts => planner_fallback_fonts
        end
        if item.published_time_slot
            pdf.text item.published_time_slot.start.strftime(@day_and_time_format), :fallback_fonts => planner_fallback_fonts
        elsif item.parent
            pdf.text item.parent.published_time_slot.start.strftime(@day_and_time_format), :fallback_fonts => planner_fallback_fonts
        end
        pdf.text "<b>Participants:</b> " + item.published_programme_item_assignments.find_all {|x| x.role == PersonItemRole['Participant'] || PersonItemRole['OtherParticipant'] || x.role == PersonItemRole['Moderator']}.collect{|p| p.person.getFullPublicationName + (p.role == PersonItemRole['Moderator'] ? ' (M)' : '') }.join(","), :inline_format => true, :fallback_fonts => planner_fallback_fonts
        pdf.text "<b>Description:</b> " + sanitize(item.precis, tags: %w(b i u strikethrough sub sup font link color), attributes: %w(href size name character_spacing rgb cmyk) ), :fallback_fonts => planner_fallback_fonts, :inline_format => true if item.precis
    end
end

prawn_document(:page_size => @page_size, :page_layout => :landscape) do |pdf|
    render "font_setup", :pdf => pdf

    page_height = pdf.bounds.top_right[1]
    page_width = pdf.bounds.top_right[0]

    first_page = true
    
    if @by_time
        @items.each do |item|
            item.published_programme_item_assignments.find_all{|x| x.role == PersonItemRole['Participant'] || PersonItemRole['OtherParticipant'] || x.role == PersonItemRole['Moderator']}.
                    sort_by{ |a| (a.published_programme_item.parent && a.published_programme_item.parent.published_time_slot) ? a.published_programme_item.parent.published_time_slot.start : (a.published_programme_item.published_time_slot ? a.published_programme_item.published_time_slot.start : @conf_start_time) }.
                    each do |assignment|
                pdf.start_new_page if !first_page
                first_page = false
                print_assignment(pdf, item, assignment, page_width, page_height)
            end
            if item.children.size > 0
                item.children.each do |child|
                    child.published_programme_item_assignments.find_all{|x| x.role == PersonItemRole['Participant'] || PersonItemRole['OtherParticipant'] || x.role == PersonItemRole['Moderator']}.
                    each do |assignment|
                        pdf.start_new_page if !first_page
                        first_page = false
                        print_assignment(pdf, child, assignment, page_width, page_height)
                    end
                end
            end
        end
    else
        @people.each do |person|
            person.published_programme_items.collect{|i| @itemList ? (@itemList.include?(i.id.to_s) ? i : nil) : i }.compact.
                    sort_by{ |a| (a.parent && a.parent.published_time_slot) ? a.parent.published_time_slot.start : (a.published_time_slot ? a.published_time_slot.start : @conf_start_time) }.
                    each do |item|
                pdf.start_new_page if !first_page
                first_page = false
                    
                pdf.rotate 180, :origin => [page_width/2, pdf.cursor - page_height/8] do
                        pdf.font_size 80 do
                            pdf.text_box person.getFullPublicationName, 
                                    :at => [10, pdf.cursor],
                                    :width => page_width,
                                    :height => 100.pt,
                                    :overflow => :shrink_to_fit,
                                    :mi_font_size => 30,
                                    :fallback_fonts => planner_fallback_fonts
                        end
                end
                
                break if @single
                                
                #
                pdf.move_down (page_height/2 + 40.pt)
                        pdf.text item.title, :inline_format => true, :fallback_fonts => planner_fallback_fonts
                        pdf.text "<b>Part of:</b> " + item.parent.title, :inline_format => true, :fallback_fonts => planner_fallback_fonts if item.parent
                        pdf.text item.format.name, :fallback_fonts => planner_fallback_fonts if item.format
                        if item.published_room
                            pdf.text item.published_room.name + ' ' + item.published_room.published_venue.name, :fallback_fonts => planner_fallback_fonts
                        elsif item.parent
                            pdf.text item.parent.published_room.name + ' ' + item.parent.published_room.published_venue.name, :fallback_fonts => planner_fallback_fonts
                        end
                        if item.published_time_slot
                            pdf.text item.published_time_slot.start.strftime(@day_and_time_format), :fallback_fonts => planner_fallback_fonts
                        elsif item.parent
                            pdf.text item.parent.published_time_slot.start.strftime(@day_and_time_format), :fallback_fonts => planner_fallback_fonts
                        end
                        pdf.text "<b>Participants:</b> " + item.published_programme_item_assignments.find_all {|x| x.role == PersonItemRole['Participant'] || x.role == PersonItemRole['Moderator']}.collect{|p| p.person.getFullPublicationName + (p.role == PersonItemRole['Moderator'] ? ' (M)' : '') }.join(","), :inline_format => true, :fallback_fonts => planner_fallback_fonts
                        pdf.text "<b>Description:</b> " + item.precis, :inline_format => true, :fallback_fonts => planner_fallback_fonts
            end
        end
    end
    


end
