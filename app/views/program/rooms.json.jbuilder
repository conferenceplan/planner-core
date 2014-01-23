
json.array! @rooms.each do |room|
    json.partial! 'room', room: room
end
