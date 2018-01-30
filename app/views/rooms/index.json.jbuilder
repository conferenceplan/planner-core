
if @rooms
  json.array! @rooms do |room|
    json.partial! 'room', room: room
  end
end
