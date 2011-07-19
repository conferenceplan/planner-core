xml.rows do
  xml.page(@page)
  xml.total(@nbr_pages)
  xml.records(@count)
  @programmeItems.each do |programmeItem|
    xml.row({:id => programmeItem.id}) do
      xml.cell(programmeItem.title)
      if (programmeItem.format)
         xml.cell(programmeItem.format.name)
      else
         xml.cell('none')
      end
      xml.cell(programmeItem.duration)
      if programmeItem.room
        xml.cell(programmeItem.room.name)
      else
        xml.cell('')
      end
      if programmeItem.time_slot
        xml.cell(programmeItem.time_slot.start.strftime('%A'))
        xml.cell(programmeItem.time_slot.start.strftime('%H:%M'))
      else  
        xml.cell('')
        xml.cell('')
      end
      if (programmeItem.pub_reference_number)
        xml.cell(programmeItem.pub_reference_number)
      else
        xml.cell('')
      end
    end
  end
end

