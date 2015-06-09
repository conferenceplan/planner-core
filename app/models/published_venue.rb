#
#
#
class PublishedVenue < ActiveRecord::Base
  attr_accessible :lock_version, :name

  default_scope order('published_venues.sort_order asc, published_venues.name asc')

  audited :allow_mass_assignment => true
  has_many  :published_rooms #, :class_name => 'Published::Room'

  # The relates the published venue back to the original venu
  has_one :publication, :foreign_key => :published_id, :as => :published
  has_one :original, :through => :publication,
          :source => :original,
          :source_type => 'Venue'

  def address
    original.address if original
  end

end
