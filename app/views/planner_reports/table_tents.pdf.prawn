require "prawn/measurement_extensions"

# TODO - get the page size and layout from options passed in

# 1/72 of an inch
# page is 
page_height = 8.5.in
page_width = 11.in
prawn_document(:page_layout => :landscape) do |pdf|

    first_page = true
    @people.each do |person|
        pdf.start_new_page if !first_page
        first_page = false
            
        person.published_programme_items.each do |item|
            # Letter is 8.5 by 11
            pdf.rotate 180, :origin => [page_width - 6.in, pdf.cursor - 40.pt] do
                pdf.text item.title
                pdf.text item.format.name
                pdf.text item.precis
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
