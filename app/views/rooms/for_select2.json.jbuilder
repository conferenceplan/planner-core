if @grouped_rooms

  json.array! @grouped_rooms do |venue, rooms|
    json.text venue.name
    json.children do
      json.array! rooms do |room|
        json.id room.id
        json.text room.name
      end
    end
  end

end