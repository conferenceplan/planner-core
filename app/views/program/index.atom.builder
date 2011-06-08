
atom_feed do |feed|
  feed.title("Renovation Program")
  feed.updated(DateTime.now)
  
  @assignments.each do |assignment|
    feed.entry(assignment, :url => '/') do |entry|
      str = ''
      assignment.published_programme_item.people.each do |person| 
        str += person.GetFullPublicationName + ', '
      end
      entry.title(assignment.published_programme_item.title)
      entry.content(
        '<p>' + assignment.published_time_slot.start.strftime('%A %H:%M') + ' to ' + assignment.published_time_slot.end.strftime('%H:%M') + '</p>' +
        '<p>' + assignment.published_programme_item.precis + '</p>' +
        str,
        :type => 'html')
      entry.updated(assignment.published_programme_item.publication.publication_date) # needed to work with Google Reader.
    end
  end  
    
end

