#
#
#
class PublishedProgrammeItem < ActiveRecord::Base
  acts_as_audited

  has_many  :published_programme_item_assignments, :dependent => :destroy #, :class_name => 'Published::ProgrammeItemAssignment'
  has_many  :people, :through => :published_programme_item_assignments
  
  acts_as_taggable

  belongs_to :format 
  
  has_one :published_room_item_assignment, :dependent => :destroy
  has_one :published_room, :through => :published_room_item_assignment
  has_one :published_time_slot, :through => :published_room_item_assignment, :dependent => :destroy

  # The relates the published programme item back to the original programme item
  has_one :publication, :foreign_key => :published_id, :as => :published
  has_one :original, :through => :publication,
          :source => :original,
          :source_type => 'ProgrammeItem'

  def pub_number
    if pub_reference_number
      return pub_reference_number
    else
      return id.to_s
    end
  end
          
  def timeString
    return published_time_slot.start.strftime('%m%d %H:%M')
  end
  
  def shortDate
    return published_time_slot.start.strftime('%m/%d')
  end
end
