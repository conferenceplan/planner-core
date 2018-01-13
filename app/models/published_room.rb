#
#
#
class PublishedRoom < ActiveRecord::Base
  translates :name,
             touch: true,
             fallbacks_for_empty_translations: true
  globalize_accessors locales: UISettingsService.getAllowedLanguages

  default_scope {order('published_rooms.sort_order asc')}
  
  audited :allow_mass_assignment => true
  belongs_to  :published_venue
  
  has_many :published_room_item_assignments do
    def day(d) # get the room item assignments for the given day if the day parameter is used
      where(['day = ?', d]).joins(:published_time_slot).order('published_time_slots.start asc')
    end
  end
  has_many :published_programme_items, :through => :published_room_item_assignments
  has_many :published_time_slots, :through => :published_room_item_assignments
  
  # The relates the published room back to the original room
  has_one :publication, :foreign_key => :published_id, :as => :published
  has_one :original, :through => :publication,
          :source => :original,
          :source_type => 'Room'


  def self.with_public_items
    joins(:published_programme_items).where(published_programme_items: {visibility_id: Visibility['Public']})
  end
          
end
