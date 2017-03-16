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
    ) do |orig, _kopy|
      _kopy.conference_id = conference_id if  _kopy.respond_to?(:conference_id)
    end

    kopy.save!
    kopy
  end
  
end
