
if @publicationInfo
    json.publication_date   @publicationInfo.timestamp
    json.new                @publicationInfo.newitems
    json.modified           @publicationInfo.modifieditems
    json.removed            @publicationInfo.removeditems
end
