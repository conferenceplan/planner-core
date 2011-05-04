#
#
#
class Published::RoomItemAssignment < ActiveRecord::Base
  acts_as_audited

  belongs_to :room, :class_name => 'Published::Room'
  belongs_to :programme_item, :class_name => 'Published::ProgrammeItem'
  belongs_to :time_slot, :class_name => 'Published::TimeSlot'
end
