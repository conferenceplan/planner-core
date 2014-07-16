#
require "prawn/measurement_extensions"

prawn_document(:page_size => @page_size, :page_layout => @orientation) do |pdf|
    page_height = pdf.bounds.top_right[1]
    page_width = pdf.bounds.top_right[0]

    pdf.text  "#{pdf.font.inspect}"
    
    pdf.text  '<b>Item Changes</b>', :size => 20, :inline_format => true
    
    
    @item_changes.each do |k, v|
        if v[:item]

            str = '<b>' + v[:item].pub_reference_number.to_s
            str += ' ' + v[:item].title + '</b>'
            pdf.pad(5) { pdf.text str, :inline_format => true }

            # Changes to programme items
            if v[:changed]
                v[:changed].each do |k, v|
                    if (!v.blank? && (k.to_s != 'created_at'))
                        str = '<b>' + k.to_s + '</b>'
                        str += ' ' + ActionView::Base.full_sanitizer.sanitize(v[0])
                        str += ' <b>changed to</b> ' + ActionView::Base.full_sanitizer.sanitize(v[1])
                        pdf.pad(5) { pdf.text str, :inline_format => true }
                     end
                 end
            end

            # Room and time changes
            if v[:time]
                str = v[:time][:time].start.strftime('%Y-%m-%d')
                str += ' ' + v[:time][:time].start.strftime('%H:%M')
                str += ' ' + ((v[:time][:time].end - v[:time][:time].start) / 60).to_s
                pdf.pad(5) { pdf.text str }
            end
            if v[:room]
                str = v[:room][:room].name
                str += v[:room][:room].published_venue.name
                pdf.pad(5) { pdf.text str }
            end
                    
            # people added and/or dropped
            start = true
            if v[:people]
                str = ''
                v[:people].each do |person|
                    str += ', ' if !start
                    str += person[1][:action] + ' ' + person[1][:person_name] + ' (' + person[1][:role] + ")"
                    start = false
                end
                pdf.pad(5) { pdf.text str }
            end
        end
    end    
    
end
