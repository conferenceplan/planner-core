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
      
      content = "<div class='prog-change'>"
      content += "<div class='prog-schedule-item-room'>#{k.published_room.published_venue.name} #{k.published_room.name}</div>"
      if v.size > 0
        if v[:timeMove]
          content += "<div class='proc-schedule-change'>Schedule Change: "
          t = v[:timeMove][0].strftime("%A at %H:%M")
          content += "<div class='prog-schedule-change-from'>#{t}</div> has changed to "
          t = v[:timeMove][1].strftime("%A at %H:%M")
          content += "<div class='prog-schedule-change-to'>#{t}</div></div>"
        else
          t = k.published_time_slot.start.strftime("%A at %H:%M")
          content += "<div class='prog-schedule-item-time'>#{t}</div>"
        end
        if v[:roomMove] && v[:roomMove].kind_of?(Array) && v[:roomMove].size > 1
          content += "<div class='prog-room-change'>The room change: "
          r = v[:roomMove][1].name
          content += "<div class='prog-room-change-from'>#{r}</div>"
          r = v[:roomMove][0].name
          content += "<div class='prog-room-change-to'>#{r}</div></div>"
        end
      end
      content += "</div>"
      feed.entry(title, :url => '/') do |entry|
        entry.title(title)
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
      content = "<div class='prog-change'>"
      venue = k.published_room.published_venue.name
      r = k.published_room.name
      content += "<div class='prog-schedule-item-room'>#{venue}( #{r} )</div>"
      t = v[0].strftime("%A at %H:%M")
      content += "<div class='prog-schedule-item-time'>#{t}</div>"
      precis = k.precis
      content += "<div class='prog-schedule-item-description'>#{precis}</div>"
      content += "</div>"
      feed.entry(title, :url => '/') do |entry|
        entry.title(title)
        entry.content(content, :type => 'html')
        entry.updated(@lastPubDate.timestamp.utc.strftime("%Y-%m-%dT%H:%M:%S%z"))
      end
    end
  end
  
  droppedItems = @resultantChanges[:removeItem]
  if droppedItems
    #<h2>Dropped Items</h2>
    droppedItems.each do |k, v|
      title = v[:title]
      content = "<div class='prog-change'>"
      content += "dropped from "
      t = v[:info][1].getlocal().strftime("%A at %H:%M")
      content += "<div class='prog-schedule-item-time'>#{t}</div> in "
      venue = v[:info][0].published_venue.name
      room = v[:info][0].name
      content += "<div class='prog-schedule-item-room'>#{venue}( #{room} )</div>"
      content += "</div>"
      feed.entry(title, :url => '/') do |entry|
        entry.title(title)
        entry.content(content, :type => 'html')
        entry.updated(@lastPubDate.timestamp.utc.strftime("%Y-%m-%dT%H:%M:%S%z"))
      end
    end
  end
  
  peopleAdded = @resultantChanges[:addPerson]
  if peopleAdded
    #<h2>Program Participants Added to Programme Items</h2>
    peopleAdded.each do |k, v|
      content = "<div class='prog-change'>"
      title = k.title
      t = k.published_time_slot.start.getlocal().strftime("%A at %H:%M")
      content += "<div class='prog-schedule-item-time'>#{t}</div>"
      content += "<div class='prog-schedule-participants'>"
      v.each_index do |idx|
        if idx % 2 == 0
          n = v[idx].GetFullPublicationName
          content += "<div class='prog-schedule-participant'>#{n}</div> as "
          r = v[idx +1].name
          content += "<div class='prog-schedule-participant-role'>#{r}</div>"
        end
      end
      content += "</div>"
      content += "</div>"
      feed.entry(title, :url => '/') do |entry|
        entry.title(title)
        entry.content(content, :type => 'html')
        entry.updated(@lastPubDate.timestamp.utc.strftime("%Y-%m-%dT%H:%M:%S%z"))
      end
    end
  end
  
  peopleRemoved = @resultantChanges[:removePerson]
  if peopleRemoved
    #<h2>Program Participants Dropped from Particular  Programme Items</h2>
    peopleRemoved.each do |k, v|
      title = k.title
      content = "<div class='prog-change'>"
      t = k.published_time_slot.start.getlocal().strftime("%A at %H:%M")
      content += "<div class='prog-schedule-item-time'>#{t}</div>"
      content += "<div class='prog-schedule-participants'>"
      v.each_index do |idx|
        if idx % 2 == 0
          n = v[idx].GetFullPublicationName
          content += "<div class='prog-schedule-participant'>#{n}</div>"
        end
      end
      content += "</div>"
      content += "</div>"
      feed.entry(title, :url => '/') do |entry|
        entry.title(title)
        entry.content(content, :type => 'html')
        entry.updated(@lastPubDate.timestamp.utc.strftime("%Y-%m-%dT%H:%M:%S%z"))
      end
    end
  end
  
  updatedItemDetails = @resultantChanges[:updateDetails]
  if updatedItemDetails
    #<h2>Title and Description Changes</h2>
    updatedItemDetails.each do |k, v|
      content = "<div class='prog-change'>"
      title = k.title
      t = k.published_time_slot.start.strftime("%A at %H:%M")
      content += "<div class='prog-schedule-item-time'>#{t}</div>"
      venue = k.published_room.published_venue.name
      room = k.published_room.name
      content += "<div class='prog-schedule-item-room'>#{venue}( #{room} )</div>"
      if v.size > 0
        if v.kind_of?(Array)
          v.each do |change|
            change.each do |name, vals|
              content += "<div class='prog-update-old-value'>#{name}</div> changed to:"
              content += "<div class='prog-update-new-value'>#{vals[1]}</div>"
            end
          end
        end
      end
      content += "</div>"
      feed.entry(title, :url => '/') do |entry|
        entry.title(title)
        entry.content(content, :type => 'html')
        entry.updated(@lastPubDate.timestamp.utc.strftime("%Y-%m-%dT%H:%M:%S%z"))
      end
    end
  end
  
end
