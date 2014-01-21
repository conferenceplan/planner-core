require "prawn/measurement_extensions"

prawn_document(:page_size => @page_size, :page_layout => :landscape) do |pdf|
    page_height = pdf.bounds.top_right[1]
    page_width = pdf.bounds.top_right[0]

    first_page = true
    @people.each do |person|
            
        person.published_programme_items.each do |item|
            pdf.start_new_page if !first_page
            first_page = false
            
            pdf.rotate 180, :origin => [page_width/2, pdf.cursor - 40.pt] do
                pdf.text item.title, :inline_format => true
                pdf.text item.format.name
                pdf.text item.published_room.name + ' ' + item.published_room.published_venue.name
                pdf.text item.published_time_slot.start.strftime('%A %H:%M %y-%m-%d')
            end
                        
            #
            pdf.move_down page_height/2
            pdf.font_size 80 do
                pdf.text_box person.getFullPublicationName, 
                        :at => [10, pdf.cursor],
                        :width => page_width,
                        :height => 100.pt,
                        :overflow => :shrink_to_fit,
                        :mi_font_size => 30
            end
        end
    end

end
