
if @programmeItem

    json.partial! 'item', item: @programmeItem, 
                        participants: nil, 
                        other_participants: nil, 
                        moderators: nil, 
                        reserves: nil, 
                        invisibles: nil
    
end
