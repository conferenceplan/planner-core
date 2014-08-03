require "prawn/measurement_extensions"

prawn_document(:page_size => @page_size, :page_layout => :landscape) do |pdf|
    page_height = pdf.bounds.top_right[1]
    page_width = pdf.bounds.top_right[0]

    first_page = true
    
    if @by_time
        @items.each do |item|
            item.published_programme_item_assignments.find_all{|x| x.role == PersonItemRole['Participant'] || x.role == PersonItemRole['Moderator']}.each do |assignment|
                person = assignment.person
                pdf.start_new_page if !first_page
                first_page = false
                    
                pdf.rotate 180, :origin => [page_width/2, pdf.cursor - page_height/8] do
                        pdf.font_size 80 do
                            pdf.text_box person.getFullPublicationName, 
                                    :at => [10, pdf.cursor],
                                    :width => page_width,
                                    :height => 100.pt,
                                    :overflow => :shrink_to_fit,
                                    :mi_font_size => 30
                        end
                end
                
                break if @single
                                
                #
                pdf.move_down (page_height/2 + 40.pt)
                        pdf.text item.title, :inline_format => true
                        pdf.text item.format.name if item.format
                        pdf.text item.published_room.name + ' ' + item.published_room.published_venue.name
                        pdf.text item.published_time_slot.start.strftime('%A %H:%M %y-%m-%d')
                        pdf.text "<b>Participants:</b> " + item.published_programme_item_assignments.find_all {|x| x.role == PersonItemRole['Participant'] || x.role == PersonItemRole['Moderator']}.collect{|p| p.person.getFullPublicationName + (p.role == PersonItemRole['Moderator'] ? ' (M)' : '') }.join(","), :inline_format => true
                        pdf.text "<b>Description:</b> " + item.precis, :inline_format => true
            end
        end
    else
        @people.each do |person|
            person.published_programme_items.collect{|i| @itemList ? (@itemList.include?(i.id.to_s) ? i : nil) : i }.compact.each do |item|
                pdf.start_new_page if !first_page
                first_page = false
                    
                pdf.rotate 180, :origin => [page_width/2, pdf.cursor - page_height/8] do
                        pdf.font_size 80 do
                            pdf.text_box person.getFullPublicationName, 
                                    :at => [10, pdf.cursor],
                                    :width => page_width,
                                    :height => 100.pt,
                                    :overflow => :shrink_to_fit,
                                    :mi_font_size => 30
                        end
                end
                
                break if @single
                                
                #
                pdf.move_down (page_height/2 + 40.pt)
                        pdf.text item.title, :inline_format => true
                        pdf.text item.format.name if item.format
                        pdf.text item.published_room.name + ' ' + item.published_room.published_venue.name
                        pdf.text item.published_time_slot.start.strftime('%A %H:%M %y-%m-%d')
                        pdf.text "<b>Participants:</b> " + item.published_programme_item_assignments.find_all {|x| x.role == PersonItemRole['Participant'] || x.role == PersonItemRole['Moderator']}.collect{|p| p.person.getFullPublicationName + (p.role == PersonItemRole['Moderator'] ? ' (M)' : '') }.join(","), :inline_format => true
                        pdf.text "<b>Description:</b> " + item.precis, :inline_format => true
            end
        end
    end
    


end
