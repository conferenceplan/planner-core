
if @programmeItem

    json.partial! 'item', item: @programmeItem, 
                        participants: @participantAssociations,
                        other_participants: @otherParticipantAssociations,
                        moderators: @moderatorAssociations, 
                        reserves: @reserveAssociations, 
                        invisibles: @invisibleAssociations,
                        default_person_img: DefaultBioImage.first
    
end
