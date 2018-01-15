class Room < ActiveRecord::Base
  attr_accessible :name, :purpose, :comment, :venue_id, :lock_version, :sort_order

  before_destroy :check_for_use
  
  include RankedModel
  ranks :sort_order, :with_same => :venue_id 
  
  default_scope {order('rooms.sort_order asc')}
  
  belongs_to  :venue
  
  # this is a many to many
  has_many :room_item_assignments, :dependent => :destroy do
    def day(d) # get the room item assignments for the given day if the day parameter is used
        references([:programme_item, :time_slot]).
        where(['day = ?', d]).
        joins(:time_slot).order('time_slots.start asc')
    end
  end
  has_many :programme_items, :through => :room_item_assignments # through the room item assignment
  has_many :time_slots, :through => :room_item_assignments #, :source_type => 'TimeSlot'

  has_many :room_setups
  has_many :setup_types, :through => :room_setups
  belongs_to :room_setup, foreign_key: "setup_id"
  
  has_one :publication, :foreign_key => :original_id, :as => :original
  has_one :published, :through => :publication,
          :source => :published,
          :source_type => 'PublishedRoom'

  audited :associated_with => :venue, :allow_mass_assignment => true
  
  has_many :equipment

  def removeAllTimes()
    self.room_item_assignments.each do |ts|
      TimeSlot.delete(ts.time_slot_id)
      RoomItemAssignment.delete(ts.id)
    end
  end


  def check_for_use
    in_use = (self.room_item_assignments.any? || Link.where(linkedto_type: 'Room', linkedto_id: self.id).any? )

    if in_use
      raise I18n.t('planner.core.locations.cannot-delete-in-use').html_safe
    end
  end

end
