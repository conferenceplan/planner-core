#
require "prawn/measurement_extensions"

prawn_document(:page_size => @page_size, :page_layout => @orientation) do |pdf|
    render "font_setup", :pdf => pdf
    
    page_height = pdf.bounds.top_right[1]
    page_width = pdf.bounds.top_right[0]

    pdf.text  '<b>Item Changes</b>', :size => 20, :inline_format => true, :fallback_fonts => fallback_fonts
    
    @item_changes.each do |k, v|
        if v[:item]

            str = '<b>' + v[:item].pub_reference_number.to_s
            str += ' ' + v[:item].title + '</b>'
            pdf.pad(5) { pdf.text str, :inline_format => true, :fallback_fonts => fallback_fonts }

            if v[:changed]
                v[:changed].each do |k, v|
                    if (!v.blank? && (k.to_s != 'created_at'))
                        str = '<b>' + k.to_s + '</b>'
                        str += ' ' + ActionView::Base.full_sanitizer.sanitize(v[0])
                        str += ' <b>changed to</b> ' + ActionView::Base.full_sanitizer.sanitize(v[1])
                        pdf.pad(5) { pdf.text  str, :inline_format => true, :fallback_fonts => fallback_fonts }
                     end
                 end
            end

            if v[:time]
                str = v[:time][:time].start.strftime('%Y-%m-%d')
                str += ' ' + v[:time][:time].start.strftime(@plain_time_format)
                str += ' ' + ((v[:time][:time].end - v[:time][:time].start) / 60).to_s
                pdf.pad(5) { pdf.text str, :fallback_fonts => fallback_fonts }
            end
            if v[:room]
                str = v[:room][:room].name
                str += v[:room][:room].published_venue.name
                pdf.pad(5) { pdf.text str, :fallback_fonts => fallback_fonts }
            end
                    
            start = true
            if v[:people]
                str = ''
                v[:people].each do |person|
                    str += ', ' if !start
                    str += person[1][:action] + ' ' + person[1][:person_name] + ' (' + person[1][:role] + ")"
                    start = false
                end
                pdf.pad(5) { pdf.text str, :fallback_fonts => fallback_fonts }
            end
        end
    end    
    
    pdf.text  '<b>Deleted Items</b>', :size => 20, :inline_format => true, :fallback_fonts => fallback_fonts
    
    @item_changes.keep_if{|k,v| v[:item] == nil}.each do |k, v|
        pdf.text   v[:deleted][:title], :fallback_fonts => fallback_fonts
    end
    
    pdf.text  '<b>New Items</b>', :size => 20, :inline_format => true, :fallback_fonts => fallback_fonts

    @changes[:new_items].each do |item_id|
        item = PublishedProgrammeItem.find(item_id)

        pdf.text  item.pub_reference_number.to_s + ' <b>' + item.title + '</b>', :inline_format => true, :fallback_fonts => fallback_fonts
        pdf.text  item.published_room.name + ' ' + item.published_room.published_venue.name, :fallback_fonts => fallback_fonts
        pdf.text  item.published_time_slot.start.strftime('%A') + ' ' + item.published_time_slot.start.strftime(@plain_time_format), :fallback_fonts => fallback_fonts
        pdf.text  item.duration.to_s + ' minutes, ' + (item.format ? item.format.name : ''), :fallback_fonts => fallback_fonts
        pdf.text  item.precis , :inline_format => true, :fallback_fonts => fallback_fonts
        pdf.text item.published_programme_item_assignments.find_all {|x| x.role == PersonItemRole['Participant'] || x.role == PersonItemRole['Moderator']}.collect{|p| 
                p.person.getFullPublicationName + (p.role == PersonItemRole['Moderator'] ? ' (M)' : '') }.join("\n"), :fallback_fonts => fallback_fonts
        pdf.pad_bottom(5) {pdf.text ' ', :fallback_fonts => fallback_fonts }
    end
    
    pdf.text  '<b>Removed People</b>', :size => 20, :inline_format => true, :fallback_fonts => fallback_fonts
    
    @changes[:removedPeople].each do |person_id|
        if Person.exists? person_id
            person = Person.find person_id
            pdf.pad_bottom(5) {pdf.text  person.getFullPublicationName, :fallback_fonts => fallback_fonts }
        end
    end
end
