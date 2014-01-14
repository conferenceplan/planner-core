
require "prawn/measurement_extensions"

nbrColumns = 10

# TODO - get the page size and layout from options passed in
prawn_document(:page_size => "TABLOID", :page_layout => :landscape) do |pdf|

    allRooms = @rooms.collect {|r| r.name}
    nbrTables = (allRooms.length / nbrColumns) + 1
    start = 0
    # Split into x tabels where x = number of rooms / nbrColumns
    (1..nbrTables).each do |nbr|
        rooms = allRooms.slice(start,nbrColumns)
        table = [['Time'].concat(rooms)]
        @times.chunk { |n| n.start }.collect {|items|
            row = Array.new(nbrColumns+1)
            row[0] = items[0].strftime('%A %H:%M')

            items[1].each do |item|
                idx = @rooms.index{|x| x.id == item.rooms[0].id }
                if (idx && ((start..(start+(nbrColumns-1))).member? idx ))
                    row[idx - start + 1] = (pdf.make_cell :content => item.programme_items[0].title)
                end
            end

            table.concat [row]
        }
        
        pdf.table(table,:header => true) do
            cells.style :overflow => :shrink_to_fit, :width => 100, :height => 50, :min_font_size => 8
        end
        
        start += nbrColumns
        
        pdf.move_down 20

    end

    pdf.repeat(:all) do
        pdf.draw_text "Program", :at => [pdf.bounds.left, pdf.bounds.top + 10]
    end
    
    pdf.number_pages "page <page> of <total>", {:at => [0 , 0], :width => 150, :align => :left, :start_count_at => 1}

end
