
if @publicationInfo
    json.publication_date   @publicationInfo.timestamp
    json.new_items          @publicationInfo.newitems
    json.modified           @publicationInfo.modifieditems
    json.removed            @publicationInfo.removeditems
end
