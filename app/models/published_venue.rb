#
#
#
class PublishedVenue < ActiveRecord::Base
  translates :name,
             touch: true,
             fallbacks_for_empty_translations: true
  globalize_accessors locales: UISettingsService.getAllowedLanguages

  default_scope {order('published_venues.sort_order asc, published_venues.name asc')}

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

  def postal_address
    original.postal_address if original
  end

end
