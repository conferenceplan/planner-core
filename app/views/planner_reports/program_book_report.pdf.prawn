require "prawn/measurement_extensions"

prawn_document(:page_size => @page_size, :page_layout => @orientation) do |pdf|
    render "font_setup", :pdf => pdf
    
    page_height = pdf.bounds.top_right[1]
    page_width = pdf.bounds.top_right[0]
    nbrColumns = (page_width / 110).to_i

    allRooms = @rooms.collect {|r| r.name}
    nbrTables = (allRooms.length / nbrColumns) + 1
    start = 0
    # Split into x tabels where x = number of rooms / nbrColumns
    (1..nbrTables).each do |nbr|
        rooms = allRooms.slice(start,nbrColumns)
        table = [['Time'].concat(rooms)]
        @times.chunk { |n| n.start }.collect {|items|
            row = Array.new(nbrColumns+1)
            row[0] = items[0].strftime(@time_format)

            items[1].each do |item|
                if item.rooms[0]
                    idx = @rooms.index{|x| x.id == item.rooms[0].id }
                    if (idx && ((start..(start+(nbrColumns-1))).member? idx ))
                        row[idx - start + 1] = (pdf.make_cell :content => item.programme_items[0].title)
                    end
                end
            end

            table.concat [row]
        }
        
        pdf.table(table, :header => true, :cell_style => {:font => :kai}) do
            cells.style :overflow => :shrink_to_fit, :width => 100, :height => 50, :min_font_size => 8
        end
        
        start += nbrColumns
        
        pdf.move_down 20

    end

    pdf.repeat(:all) do
        pdf.draw_text "Program", :at => [pdf.bounds.left, pdf.bounds.top + 10], :fallback_fonts => fallback_fonts
    end
    
    pdf.number_pages "page <page> of <total>", {:at => [0 , 0], :width => 150, :align => :left, :start_count_at => 1}
end
