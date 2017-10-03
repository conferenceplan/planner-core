class EditedBio < ActiveRecord::Base
  attr_accessible :lock_version, :person_id, :photourl, :bio_en, :bio_fr, :bio_pl

  translates :bio, touch: true, fallbacks_for_empty_translations: true
  globalize_accessors :locales => UISettingsService.getAllowedLanguages

  belongs_to  :person 

  has_social_media :facebook, :twitterinfo, :linkedin, :youtube, :twitch, 
                   :instagram, :flickr, :reddit, :othersocialmedia, :website

  audited :associated_with => :person, :allow_mass_assignment => true
  
end
