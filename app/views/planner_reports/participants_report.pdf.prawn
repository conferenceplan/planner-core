#
require "prawn/measurement_extensions"
require "open-uri"

prawn_document(:page_size => @page_size, :page_layout => @orientation) do |pdf|
    render "font_setup", :pdf => pdf
    
    page_height = pdf.bounds.top_right[1]
    page_width = pdf.bounds.top_right[0]

    pdf.font "Open Sans"


    # Do we want one page per person?
    @people.each do |person|
        person_name = pdf.make_table(
                    [[person.getFullPublicationName],[person.job_title],[person.company]],
                    :column_widths => { 0 => (page_width - 140) },
                    :cell_style => {:inline_format => true, :align => :center}
                    ) do
                        row(0).size = 30
                        cells.border_width = 0
                    end
    
        title = pdf.make_table([[(person.bio_image ? ({:image => open(person.bio_image.bio_picture.url), :fit => [100, 100] }) : '') , 
                        person_name
                    ]],
                    :column_widths => { 0 => 100, 1 => (page_width - 140) },
                    :cell_style => {:inline_format => true}
                    ) do 
                        cells.border_width = 0
                        cells.background_color = "FAFAFA"
                    end

        item_cell = []
        person.programmeItemAssignments.each do |ia|
            if ia.programmeItem.time_slot && (@allowed_roles.include? ia.role)
                item_cell << [(ia.programmeItem.short_title.blank? ? ia.programmeItem.title : ia.programmeItem.short_title)]
            end
        end
        item_cell_table = pdf.make_table(item_cell,
                            :column_widths => { 0 => (page_width - 140) }
        ) do
            cells.border_width = 0
        end

        t = pdf.make_table([
                [ title ],
                [ person.bio ],
                [ item_cell_table ]
            ],
            :cell_style => {:inline_format => true},
            :width => (page_width - 40)
        ) do
          cells.border_width = 0

          row(0).borders = [:top]
          row(0).border_width = 2
          row(1).padding = 5
          row(2).borders = [:top, :bottom]
          row(2).border_lines = [:dashed, :solid, :solid, :solid]
          row(2).border_top_width = 0.5
          row(2).border_bottom_width = 2
        end

        # pdf.text t.height.to_s
        if pdf.cursor < t.height
            pdf.start_new_page
        end

        t.draw
        pdf.move_down 20

    end

end
