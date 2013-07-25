xml.people do
  @people.each do |p|
    xml.person do
      xml.name(p.getFullName())
      p.email_addresses.each do |addr|
        if addr.isdefault
          xml.email(addr.email)
        end
      end
      xml.items do
        p.programmeItems.each do |itm|
          if itm.room # The item has to be assigned to a room and time i.e. it is scheduled
            xml.item do
              xml.title(itm.title)
              xml.room(itm.room.name + " (" + itm.room.venue.name + ")")
              xml.time(itm.time_slot.start.strftime('%A %H:%M') + " to " + itm.time_slot.end.strftime('%H:%M'))
              xml.description(itm.precis)
              xml.participants do
                itm.programme_item_assignments.each do |asg| #.people.each do |part|
                  if asg.role == PersonItemRole['Participant'] || asg.role == PersonItemRole['Moderator']
                    name = asg.person.getFullName()
                    name += " (M)" if asg.role == PersonItemRole['Moderator']
                    xml.participant do
                      xml.name(name)
                      asg.person.email_addresses.each do |addr|
                        if addr.isdefault && (!@NoShareEmailers.index(asg.person))
                          xml.email(addr.email)
                        end
                      end
                    end
                  end
                end
              end
              xml.equipment do
                if itm.equipment_types.size == 0
                  xml.piece("No Equipment Needed")
                end
                itm.equipment_types.each do |equip|
                  xml.piece(equip.description)
                end
              end
            end
          end
        end
      end
    end
  end
end
