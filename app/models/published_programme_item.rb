#
#
#
class PublishedProgrammeItem < ActiveRecord::Base
  acts_as_audited

  has_many  :published_programme_item_assignments #, :class_name => 'Published::ProgrammeItemAssignment'
  has_many  :people, :through => :published_programme_item_assignments
  
  belongs_to :format 
  
  has_one :published_room_item_assignment #, :class_name => 'Published::RoomItemAssignment'
  has_one :published_room, :through => :published_room_item_assignment
  has_one :published_time_slot, :through => :published_room_item_assignment

  # The relates the published programme item back to the original programme item
  has_one :publication, :foreign_key => :published_id
  has_one :original, :through => :publication,
          :source => :original,
          :source_type => 'ProgrammeItem'

end
