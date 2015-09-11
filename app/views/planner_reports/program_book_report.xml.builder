xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.program do
    @times.chunk { |n| n.start }.each do |items|
        xml.time do
            xml.start do
                xml.day items[0].strftime('%A')
                xml.time items[0].strftime('%H:%M')
            end
            items[1].each do |item|
                xml.item do
                    render(:partial => "program_book_item", :locals => {:builder => xml, :item => item})
                    if item.programme_items[0].children.size > 0
                        xml.child_items do
                            item.programme_items[0].children.each do |sub_item|
                                render(:partial => "program_book_child_item", :locals => {:builder => xml, :item => sub_item})
                            end
                        end
                    end
                end
            end
        end
    end
end
