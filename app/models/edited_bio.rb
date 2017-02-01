class EditedBio < ActiveRecord::Base
  attr_accessible :lock_version, :person_id, :bio, :photourl
  belongs_to  :person 

  has_social_media :facebook, :twitterinfo, :linkedin, :youtube, :twitch, 
                   :instagram, :flickr, :reddit, :othersocialmedia, :website

  audited :associated_with => :person, :allow_mass_assignment => true
  
end
