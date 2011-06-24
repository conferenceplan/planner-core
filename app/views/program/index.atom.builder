
atom_feed do |feed|
  feed.title("Renovation Program")
  feed.updated(DateTime.now)
  
  @programmeItems.each do |item|
    feed.entry(item, :url => '/') do |entry|
      str = ''
      item.people.each do |person| 
        str += '<a href="http://renovationsf.org/participants/' + person.GetFullPublicationName.gsub(/[ \.-]/,'').downcase + '.php">' + person.GetFullPublicationName + '</a>, '
      end
      entry.title(item.title)
      entry.content(
        '<p>' + item.published_time_slot.start.strftime('%A %H:%M') + ' to ' + item.published_time_slot.end.strftime('%H:%M') + '</p>' +
        '<p>' + item.published_room.published_venue.name + ' '+ item.published_room.name + '</p>' +
        '<p>' + item.precis + '</p>' +
        '<p>' + item.duration.to_s + ' minutes</p>' +
        str +
        '<p>' + item.tags_on(:PrimaryArea).to_s + '</p>',
        :type => 'html')
      entry.updated(item.publication.publication_date) # needed to work with Google Reader.
    end
  end
  
end

