#
# Use this to generate the ATOM feed for the program changes
#
atom_feed do |feed|
  feed.title("Renovation Program Updates")
  feed.updated(@lastPubDate.timestamp)
  
  changedItems = @resultantChanges[:update]
  if changedItems
    #<h2>Item Time and Room Changes</h2>
    changedItems.each do |k, v|
      title = k.title
      
      content = "#{k.published_room.published_venue.name} #{k.published_room.name} "
      if v.size > 0
        if v[:timeMove]
          t1 = v[:timeMove][0].strftime("%A at %H:%M")
          t2 = v[:timeMove][1].strftime("%A at %H:%M")
          content += "Schedule Change: #{t1} has changed to #{t2}.<br/>"
        else
          t = k.published_time_slot.start.strftime("%A at %H:%M")
          content += " at #{t}<br/>"
        end
        if v[:roomMove] && v[:roomMove].kind_of?(Array) && v[:roomMove].size > 1
          r1 = v[:roomMove][1].name
          r2 = v[:roomMove][0].name
          content += "The room has changed: "
          content += "from #{r1} to #{r2}"
        end
      end

      feed.entry(v, :url => 'http://renovationsf.org/prog-get.php') do |entry|
        entry.title(markdown(title))
        entry.content(content, :type => 'html')
        entry.updated(@lastPubDate.timestamp.utc.strftime("%Y-%m-%dT%H:%M:%S%z"))
      end
    end
  end
  
  addedItems = @resultantChanges[:new]
  if addedItems
    #<h2>New Items Added to Program</h2>
    addedItems.each do |k, v|
      title = k.title
      venue = k.published_room.published_venue.name
      r = k.published_room.name
      t = v[0].strftime("%A at %H:%M")
      precis = k.precis
      content = "Has been added to the progam, #{t} in #{venue}( #{r} )<br/><br/>#{precis}"

      feed.entry(v, :url => 'http://renovationsf.org/prog-get.php') do |entry|
        entry.title(markdown(title))
        entry.content(content, :type => 'html')
        entry.updated(@lastPubDate.timestamp.utc.strftime("%Y-%m-%dT%H:%M:%S%z"))
      end
    end
  end
  
  droppedItems = @resultantChanges[:removeItem]
  if droppedItems
    droppedItems.each do |k, v|
      title = v[:title]
      t = v[:info][1].strftime("%A at %H:%M")
      venue = v[:info][0].published_venue.name
      room = v[:info][0].name
      content = "Has been dropped. From #{venue}( #{room} ) at #{t}."

      feed.entry(v, :url => 'http://renovationsf.org/prog-get.php') do |entry|
        entry.title(markdown(title))
        entry.content(content, :type => 'html')
        entry.updated(@lastPubDate.timestamp.utc.strftime("%Y-%m-%dT%H:%M:%S%z"))
      end
    end
  end
  
  peopleAdded = @resultantChanges[:addPerson]
  if peopleAdded
    peopleAdded.each do |k, v|
      title = k.title
      t = k.published_time_slot.start.strftime("%A at %H:%M")
      content = "#{t}. Program Participants have been added: <br/>"
      v.each_index do |idx|
        if idx % 2 == 0
          n = v[idx].GetFullPublicationName
          r = v[idx +1].name
          content += "<b>#{n}</b> as a <em>#{r}</em><br/>"
        end
      end
      feed.entry(v, :url => 'http://renovationsf.org/prog-get.php') do |entry|
        entry.title(markdown(title))
        entry.content(content, :type => 'html')
        entry.updated(@lastPubDate.timestamp.utc.strftime("%Y-%m-%dT%H:%M:%S%z"))
      end
    end
  end
  
  peopleRemoved = @resultantChanges[:removePerson]
  if peopleRemoved
    peopleRemoved.each do |k, v|
      title = k.title
      t = k.published_time_slot.start.strftime("%A at %H:%M")
      content = "#{t}. The following Program Participants have been dropped:<br/>"
      v.each_index do |idx|
        if idx % 2 == 0
          n = v[idx].GetFullPublicationName
          content += "#{n}<br/>"
        end
      end

      feed.entry(v, :url => 'http://renovationsf.org/prog-get.php') do |entry|
        entry.title(markdown(title))
        entry.content(content, :type => 'html')
        entry.updated(@lastPubDate.timestamp.utc.strftime("%Y-%m-%dT%H:%M:%S%z"))
      end
    end
  end
  
  
  updatedItemDetails = @resultantChanges[:detailUpdate]
  if updatedItemDetails
    updatedItemDetails.each do |k, v|
      title = k.title
      t = k.published_time_slot.start.strftime("%A at %H:%M")
      venue = k.published_room.published_venue.name
      room = k.published_room.name
      content = "#{t} in #{venue}( #{room} ) has been updated <br/>"
      if v.size > 0
        if v.kind_of?(Array)
          v.each do |change|
            change.each do |name, vals|
              changedv = name == 'precis' ? markdown(vals[1]) : vals[1]
              content += "#{name} has been changed to: \"#{vals[1]}\" <br/>"
            end
          end
        end
      end

      feed.entry(v, :url => 'http://renovationsf.org/prog-get.php') do |entry|
        entry.title(markdown(title))
        entry.content(content, :type => 'html')
        entry.updated(@lastPubDate.timestamp.utc.strftime("%Y-%m-%dT%H:%M:%S%z"))
      end
    end
  end
  
end
