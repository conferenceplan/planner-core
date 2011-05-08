#
#
#
class PublishedRoomItemAssignment < ActiveRecord::Base
  acts_as_audited

  belongs_to :published_room #, :class_name => 'Published::Room'
  belongs_to :published_programme_item #, :class_name => 'Published::ProgrammeItem'
  belongs_to :published_time_slot #, :class_name => 'Published::TimeSlot'
end
