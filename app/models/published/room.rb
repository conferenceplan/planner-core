#
#
#
class Published::Room < ActiveRecord::Base
  belongs_to  :venue, :class_name => 'Published::Venue'
  has_many :room_item_assignments, :class_name => 'Published::RoomItemAssignment' do
    def day(d) # get the room item assignments for the given day if the day parameter is used
    end
  end
  has_many :programme_items, :through => :room_item_assignments # through the room item assignment
  has_many :time_slots, :through => :room_item_assignments #, :source_type => 'TimeSlot'

  # The relates the published room back to the original room
  has_one :publication, :class_name => 'Published::Publication'
  has_one :original, :through => :publication, #, :class_name => 'Published::Publication',
          :source => :original,
          :source_type => 'Room'

end
