
json.array! @room_setups do |setup|

    json.partial! 'setup', setup: setup 

end
