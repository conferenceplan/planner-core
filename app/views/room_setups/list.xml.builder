xml.rows do
  xml.page(@page)
  xml.total(@nbr_pages)
  xml.records(@count)
  @room_setups.each do |room_setup|
    xml.row({:id => room_setup.id}) do
      room = Room.find(room_setup.room_id)
      xml.cell(room.name)
      xml.cell(SetupType.find(room_setup.setup_type_id).name)
      xml.cell(room_setup.capacity)
      xml.cell(room.setup_id==room_setup.id)
    end
  end
end
