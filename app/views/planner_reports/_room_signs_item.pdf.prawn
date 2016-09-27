
left_part = pdf.make_table([
                [
                    "<b>" + assignment.published_time_slot.start.strftime(@plain_time_format) + "</b>"
                ],
                [
                    " - " + assignment.published_time_slot.end.strftime(@plain_time_format)
                ],
            ], :cell_style => { :inline_format => true, :overflow => :shrink_to_fit } ) do
                cells.borders = []
                row(1).size = 10
                row(2).size = 5
            end

first_person = true
personText = ""
assignment.published_programme_item.published_programme_item_assignments.collect {|a| ([PersonItemRole['Participant'],PersonItemRole['Moderator']].include? a.role) ? a : nil}.compact.each do |p|
    personText += ', ' if !first_person
    first_person = false
    personText += p.person.getFullPublicationName 
    personText += ' (' + p.role.name[0] + ')' if p.role == PersonItemRole['Moderator']
end

data = [
            [left_part, "<b>" + assignment.published_programme_item.title + "</b>"],
            ['', personText]
        ]

if ! assignment.published_programme_item.precis.blank? && @include_desc
    data.concat [['', sanitize(assignment.published_programme_item.precis, tags: %w(b i u strikethrough sub sup font link color), attributes: %w(href size name character_spacing rgb cmyk) ) ]]
end

pdf.table(data,
    :cell_style => { :inline_format => true, :border_color => "D0D0D0", :disable_wrap_by_char => true }, :width => pdf.bounds.width ) do
    cells.borders = []
    column(0).width = 70
    row(0).column(1).size = 26
    row(0).column(1).valign = :top
    row(1).column(1).size = 16
    if @include_desc
        row(2).column(1).size = 10
    end
end

if assignment.published_programme_item.children
    assignment.published_programme_item.children.each do |child|

        first_person = true
        personText = ""
        child.published_programme_item_assignments.collect {|a| ([PersonItemRole['Participant'],PersonItemRole['Moderator']].include? a.role) ? a : nil}.compact.each do |p|
            personText += ', ' if !first_person
            first_person = false
            personText += p.person.getFullPublicationName 
            personText += ' (' + p.role.name[0] + ')' if p.role == PersonItemRole['Moderator']
        end

        data = [
            ['', "<b>" + child.title + "</b>"],
            ['', personText]
        ]
        pdf.table(data,
            :cell_style => { :inline_format => true, :border_color => "D0D0D0", :disable_wrap_by_char => true }, :width => pdf.bounds.width ) do
            column(0).borders = []
            column(1).borders = [:left,:right]
            row(0).column(1).borders = [:top,:left,:right]
            row(1).column(1).borders = [:bottom,:left,:right]

            column(0).width = 70
            row(0).column(1).size = 16
            row(0).column(1).valign = :top
            row(1).column(1).size = 8
        end
        pdf.move_down 0.1.in
    end
end
