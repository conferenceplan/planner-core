
json.total @total

json.rows @rooms do |room|

    json.partial! 'room', room: room 
    
end