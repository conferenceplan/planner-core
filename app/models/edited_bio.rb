class EditedBio < ActiveRecord::Base
  attr_accessible :lock_version, :bio, :website, :twitterinfo, :othersocialmedia, :photourl, :facebook, :person_id
  belongs_to  :person 

  audited :associated_with => :person, :allow_mass_assignment => true
  
  def twitterid
    /[^\/|^@]+$/.match(twitterinfo).to_s
  end
  
  def facebookid
    /[^\/|^@]+$/.match(facebook).to_s
  end

end
