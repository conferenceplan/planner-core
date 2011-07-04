#
# Use this to generate the ATOM feed for the program changes
#
atom_feed do |feed|
  feed.title("Renovation Program Updates")
  feed.updated(@lastPubDate.timestamp)
  
  @resultantChanges.each do |key, val|
    if key.kind_of?(PublishedProgrammeItem)
      title = key.title
      content = ''
    else
      title = key
      content = '' + val.to_s
    end
    feed.entry(title, :url => '/') do |entry|
      entry.title(title)
      entry.content(content, :type => 'html')
      entry.updated(@lastPubDate.timestamp.utc.strftime("%Y-%m-%dT%H:%M:%S%z"))
    end
  end

end

  # { programmeItem => [action, action, action] }
  # action == {'timeMove' => [from, to]}
  # action == {'roomMove' => to}
  # action == 'add'

