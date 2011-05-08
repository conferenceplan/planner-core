#
#
#
class PublishedRoom < ActiveRecord::Base
  belongs_to  :published_venue #, :class_name => 'Published::Venue'
  has_many :published_room_item_assignments do #, :class_name => 'Published::RoomItemAssignment' do
    def day(d) # get the room item assignments for the given day if the day parameter is used
      #find(:all, :conditions => ['day = ?', d], :joins => :time_slot, :order => 'time_slots.start asc')
    end
  end
  has_many :published_programme_items, :through => :published_room_item_assignments # through the room item assignment
  has_many :published_time_slots, :through => :published_room_item_assignments #, :source_type => 'TimeSlot'
  
  # The relates the published room back to the original room
  has_one :publication #, :class_name => 'Published::Publication'
  has_one :original, :through => :publication, #, :class_name => 'PublishedPublication',
          :source => :original,
          :source_type => 'Room'
end
