xml.rows do
  xml.page(@page)
  xml.total(@nbr_pages)
  xml.records(@count)
  @rooms.each do |room|
    xml.row({:id => room.id}) do
      xml.cell(room.name)
      if room.venue_id
         xml.cell(Venue.find(room.venue_id).name)
      else
         xml.cell()
      end
      
      setup_pointer = RoomSetup.find(room.setup_id)
	  
	  begin
		  setup = SetupType.find(setup_pointer.setup_type_id)
	      xml.cell(setup.name)
	  rescue
         xml.cell()
      end
	
      xml.cell(setup_pointer.capacity)
      
      xml.cell(room.purpose)
      xml.cell(room.comment)
      xml.cell(room.id)
    end
  end
end

