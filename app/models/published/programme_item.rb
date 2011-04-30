#
#
#
class Published::ProgrammeItem < ActiveRecord::Base
  has_many  :published_programme_item_assignments, :class_name => 'Published::ProgrammeItemAssignment'
  has_many  :people, :through => :published_programme_item_assignments
  
  has_one   :format
  
  has_one :published_room_item_assignment, :class_name => 'Published::RoomItemAssignment'
  has_one :room, :through => :published_room_item_assignment
  has_one :time_slot, :through => :published_room_item_assignment

  # The relates the published programme item back to the original programme item
  has_one :publication, :class_name => 'Published::Publication'
  has_one :original, :through => :publication, #, :class_name => 'Published::Publication',
          :source => :original,
          :source_type => 'ProgrammeItem'
end
