
if @publicationInfo
    json.publication_date   @publicationInfo.timestamp
    json.new_items          @publicationInfo.newitems
    json.modified           @publicationInfo.modifieditems
    json.removed            @publicationInfo.removeditems

    @extra_pub_index_json.each do |extra|
        json.partial! extra
    end

end
