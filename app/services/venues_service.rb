#
#
#
module VenuesService
  
  def self.duplicate_venue(old_venue, conference_id = nil, dict = {})
    # TODO - need to add tasks and requirements - also move this to multi ...
    kopy = old_venue.deep_clone(
      include: {
        rooms: {
          linked: [
            task: {categories: :category_name}, 
            requirement: {categories: :category_name}
          ]
        }
      }, 
      dictionary: dict
    ) #, :address, :postal_address]
    
    # TODO - move
    if conference_id
      kopy.conference_id = conference_id
      kopy.rooms.each do |r|
        r.conference_id = conference_id
        r.save!
      end
    end
    
    kopy.save!
    kopy
  end
  
end
