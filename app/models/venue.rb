class Venue < ActiveRecord::Base
  
  has_many  :rooms
  validates_presence_of :name

  audited :allow_mass_assignment => true

  has_one :publication, :foreign_key => :original_id, :as => :original
  has_one :published, :through => :publication,
          :source => :published,
          :source_type => 'PublishedVenue'
end
