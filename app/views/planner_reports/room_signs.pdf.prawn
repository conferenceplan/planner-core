require "prawn/measurement_extensions"

prawn_document(:page_size => @page_size, :page_layout => @orientation) do |pdf|
    render "font_setup", :pdf => pdf

    page_height = pdf.bounds.top_right[1]
    page_width = pdf.bounds.top_right[0]
    
    # Each room in each day gets a seperate page
    first_page = true
    @rooms.each do |room|
        current_day = -1
        room.published_room_item_assignments.each do |assignment|
            if (current_day != assignment.day) || @one_per_page
                pdf.start_new_page if !first_page
                first_page = false
                current_day = assignment.day
                pdf.text  '<b>' + room.name + ' - ' + room.published_venue.name + '<br>' + (Time.zone.parse(SiteConfig.first.start_date.to_s) + assignment.day.days).strftime('%A') + '</b>', :size => 16, :inline_format => true, :align => :center, :fallback_fonts => fallback_fonts
                pdf.move_down 0.25.in
            end

            if assignment.published_programme_item
                render "room_signs_item", :pdf => pdf, :assignment => assignment

                pdf.move_down 0.2.in
            end

        end
        title = ''
    end
end
