class EditedBio < ActiveRecord::Base
  attr_accessible :lock_version, :bio, :website, :twitterinfo, :othersocialmedia, :photourl, :facebook, :person_id
  belongs_to  :person 

  audited :associated_with => :person, :allow_mass_assignment => true

end
